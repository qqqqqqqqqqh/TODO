//
//  InputViewModel.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//
import RxSwift
import RxCocoa

class InputViewModel {
    
    var isInputValid: Driver<Bool> {
        return Driver.combineLatest(
            titleSubject.asDriver(),
            detailSubject.asDriver()
        ) { !$0.isEmpty && !$1.isEmpty }
    }
    
    let titleSubject = BehaviorRelay<String>(value: "")
    let detailSubject = BehaviorRelay<String>(value: "")
    let dateSubject = BehaviorRelay<Date>(value: Date())
    
    func saveTodoItem() -> Cell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let cellItem = Cell()
        cellItem.icon = "todo"
        cellItem.title = titleSubject.value
        cellItem.time = dateFormatter.string(from: dateSubject.value)
        cellItem.detail = detailSubject.value
        return cellItem
    }
}
