//
//  ViewController.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//

import RxSwift
import RxCocoa
import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDelegate {
    private var disposeBag = DisposeBag()
    let topView = UIView()
    
    let titleLabel = UILabel()
    
    let addItemButton = UIButton()
    let tableView = UITableView()
    
    private var todoList: [Cell] = []
    let viewModel = ViewModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        tableView.reloadData()
    }
    
    func setupUI() {
        view.addSubview(topView)
        topView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        topView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.text = "Todo Tools"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(75)
        }
        
        topView.addSubview(addItemButton)
        addItemButton.setTitle("+", for: .normal)
        addItemButton.setTitleColor(.black, for: .normal)
        addItemButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        addItemButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(70)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
    
    private func setupBindings() {
        addItemButton.rx.tap
            .bind { [weak self] in
                self?.addItemButtonTapped()
            }
            .disposed(by: disposeBag)
        
        viewModel.todolist
            .drive(onNext: { [weak self] list in
                guard let self = self else { return }
                self.todoList = list
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func addItemButtonTapped() {
        let inputVC = InputViewController()
        inputVC.modalPresentationStyle = .formSheet
        present(inputVC, animated: true, completion: nil)
        inputVC.didSaveTodoItem = { [weak self] newItem in
            self?.viewModel.addTodoItem(newItem)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        disposeBag = DisposeBag()
    }
    
    @objc func handleAppTermination() {
        viewModel.saveData()
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 手动创建
        let identifier: String = "lapCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        if let cell = cell {
            let cellItem = self.todoList[indexPath.row]
            cell.imageView?.image = UIImage(named: cellItem.icon)
            cell.textLabel?.text = cellItem.title
            cell.detailTextLabel?.text = "\(cellItem.time) \(cellItem.detail)"
        }
        
        return cell!
    }
    
    // 设置cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    // 选中cell后执行此方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let manageVC = ManageCellViewController()
        manageVC.modalPresentationStyle = .overFullScreen
        manageVC.selectedTodoItem = todoList[indexPath.row]
        present(manageVC, animated: true, completion: nil)
        manageVC.updateHandler = { [weak self] item, del in
            guard let self = self else { return }
            if del {
                self.viewModel.removeTodoItem(at: indexPath.row)
            } else {
                self.viewModel.modifyTodoItem(item, at: indexPath.row)
            }
        }
    }
    
}
