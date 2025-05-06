//
//  ViewModel.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//

import RxSwift
import RxCocoa

class ViewModel {
    var todolist: Driver<[Cell]> {
        return todolistSubject.asDriver()
    }
    private let todolistSubject = BehaviorRelay<[Cell]>(value: [])
    
    init() {
        loadData()
    }
    
    func addTodoItem(_ item: Cell) {
        todolistSubject.accept(todolistSubject.value + [item])
        NotificationManager.shared.scheduleNotification(for: item)
    }
    
    func modifyTodoItem(_ item: Cell, at index: Int) {
        var todolist = todolistSubject.value
        NotificationManager.shared.cancelNotification(for: todolist[index])
        todolist[index] = item
        todolistSubject.accept(todolist)
        NotificationManager.shared.scheduleNotification(for: item)
    }
    
    func removeTodoItem(at index: Int) {
        var todolist = todolistSubject.value
        NotificationManager.shared.cancelNotification(for: todolist[index])
        todolist.remove(at: index)
        todolistSubject.accept(todolist)
    }
    
    
    // MARK: - Data Persistence
    func saveData() {
        do {
            let data = try JSONEncoder().encode(todolistSubject.value)
            UserDefaults.standard.set(data, forKey: "todolist")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func loadData() {
        guard let data = UserDefaults.standard.data(forKey: "todolist") else { return }
        do {
            let decoded = try JSONDecoder().decode([Cell].self, from: data)
            todolistSubject.accept(decoded)
        } catch {
            print("Failed to load data: \(error)")
        }
    }

}

