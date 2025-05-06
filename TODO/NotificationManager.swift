//
//  Untitled.swift
//  TODO
//
//  Created by colin.qin on 2025/4/30.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotification(for todoItem: Cell) {
        let content = UNMutableNotificationContent()
        content.title = "Todo Reminder"
        content.body = "\(todoItem.title) is due now"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        let triggerDate = dateFormatter.date(from: todoItem.time)!

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        components.timeZone = TimeZone(identifier: "Asia/Shanghai")
 
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: todoItem.title,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for todoItem: Cell) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [todoItem.title]
        )
    }
}
