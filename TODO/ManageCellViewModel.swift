//
//  Untitled.swift
//  TODO
//
//  Created by colin.qin on 2025/5/6.
//
import RxSwift
import RxCocoa

class ManageCellViewModel {
    
    var isDone: Driver<Bool> {
        return isDoneSubject.asDriver()
    }
    var doneButtonColor: Driver<UIColor> {
        return isDoneSubject.asDriver()
            .map { $0 ? .gray : .systemBlue }
    }
    
    let titleSubject = BehaviorRelay<String>(value: "")
    let detailSubject = BehaviorRelay<String>(value: "")
    let dateSubject = BehaviorRelay<Date>(value: Date())
    
    
    let isDoneSubject = BehaviorRelay<Bool>(value: false)
    
    let originalItem: Cell
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }
    
    func stringToDate(_ date: String) -> Date {
        return dateFormatter.date(from: date)!
    }
    
    func dateToString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    init(item: Cell) {
        originalItem = item
        titleSubject.accept(item.title)
        detailSubject.accept(item.detail)
        dateSubject.accept(stringToDate(item.time))
        isDoneSubject.accept(item.icon == "done")
    }

    func createUpdatedItem() -> Cell {
        let item = originalItem
        item.title = titleSubject.value
        item.detail = detailSubject.value
        item.time = dateToString(dateSubject.value)
        return item
    }
    func hasChanges() -> Bool {
        return titleSubject.value != originalItem.title ||
                detailSubject.value != originalItem.detail ||
                dateToString(dateSubject.value) != originalItem.time
    }
    
    func doneTodo() -> Cell {
        originalItem.icon = "done"
        return originalItem
    }
}
