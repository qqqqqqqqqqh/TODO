//
//  InputVIewController.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//

import RxSwift
import RxCocoa
import UIKit
import SnapKit


class InputViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private let viewModel = InputViewModel()
    
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let cancelButton = UIButton()
    private let saveButton = UIButton()
    
    var didSaveTodoItem: ((Cell) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        // Title text field
        titleTextField.placeholder = "Title"
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        // Content text view
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        // Date picker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(160) // Added height constraint for date picker
        }
        
        // Buttons
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(60)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.systemBlue, for: .normal)
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.width.height.equalTo(cancelButton)
            make.right.equalToSuperview().offset(-60)
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
        
        saveButton.rx.tap
            .withLatestFrom(viewModel.isInputValid)
            .filter { $0 }
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.didSaveTodoItem?(self.viewModel.saveTodoItem())
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // Button actions
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

    }

    deinit {
        disposeBag = DisposeBag()
    }
}
