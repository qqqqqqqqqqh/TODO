//
//  ManageCellViewController.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ManageCellViewController: UIViewController {
    private var disposeBag = DisposeBag()
    
    private let titleLabel = UILabel()
    private let titleTextField = UITextField()
    private let contentLabel = UILabel()
    private let contentTextView = UITextView()
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    private let doneButton = UIButton()
    private let deleteButton = UIButton()
    private let backButton = UIButton()
    

    var selectedTodoItem: Cell?
    var viewModel: ManageCellViewModel!
    
    var updateHandler: ((Cell, Bool) -> Void)?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel = ManageCellViewModel(item: selectedTodoItem!)
        // 先填充数据，后建立绑定
        fillData()
        setupUI()
        setupBindings()
        
    }
    
    private func setupUI() {
        // Title Label
        titleLabel.text = "Title:"
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.left.equalToSuperview().offset(20)
        }
        
        // Title TextField
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(10) // 左边距label 10pt
            make.width.equalTo(310)
            make.height.equalTo(40)
        }
        
        // Content Label
        contentLabel.text = "Content:"
        view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(titleLabel)
        }
        
        // Content TextView
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        // Date Label
        dateLabel.text = "Time:"
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.left.equalTo(titleLabel)
        }
        
        // Date Picker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(160)
        }
        
        // Buttons
        doneButton.setTitle("Done", for: .normal)
        if selectedTodoItem!.icon == "done" {
            doneButton.setTitleColor(.gray, for: .normal)
        } else {
            doneButton.setTitleColor(.systemBlue, for: .normal)
        }
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(40)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(doneButton)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(doneButton)
        }
        
        backButton.setTitle("OK/Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(deleteButton)
            make.right.equalToSuperview().offset(-40)
            make.width.height.equalTo(deleteButton)
        }
    }
    
    private func setupBindings() {
        
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.titleSubject)
            .disposed(by: disposeBag)
            
        contentTextView.rx.text.orEmpty
            .bind(to: viewModel.detailSubject)
            .disposed(by: disposeBag)
            
        datePicker.rx.date
            .bind(to: viewModel.dateSubject)
            .disposed(by: disposeBag)
        
        // 按钮状态
        viewModel.isDone
            .drive { [weak self] isDone in
                guard let self = self else { return }
                self.doneButton.isEnabled = !isDone
                self.titleTextField.isEnabled = !isDone
                self.contentTextView.isEditable = !isDone
                self.datePicker.isEnabled = !isDone
            }
            .disposed(by: disposeBag)
        
        viewModel.doneButtonColor
            .drive(doneButton.rx.tintColor)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                
                if viewModel.hasChanges() {
                    self.showSaveAlert()
                } else {
                    self.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.updateHandler?(viewModel.doneTodo(), false)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.updateHandler?(viewModel.originalItem, true)
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func showSaveAlert() {
        let alert = UIAlertController(
            title: "Unsaved Changes",
            message: "Do you want to save before exiting?",
            preferredStyle: .alert
        )
        
        // 变动保存
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let item = self.viewModel.createUpdatedItem()
            // 判断
            if (item.title != "") && (item.detail != "") {
                self.updateHandler?(item, false)
                self.dismiss(animated: true)
            } else {  // 文本框为空
                let alert = UIAlertController(
                    title: "Invalid Input",
                    message: "Cannot save with empty fields",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Don't Save", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func fillData() {
        guard let item = selectedTodoItem else { return }
        titleTextField.text = item.title
        contentTextView.text = item.detail
        datePicker.date = viewModel.stringToDate(item.time)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
}
