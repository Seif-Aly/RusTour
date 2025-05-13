//
//  NotificationManager.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI
import UserNotifications

struct AppNotification: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let body:  String
    let date:  Date = .now
}

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published private(set) var items: [AppNotification] = []
    
    private init() {
        Task { await requestAuthIfNeeded() }
    }
    
    func post(title: String, body: String) {
        let notif = AppNotification(title: title, body: body)
        items.insert(notif, at: 0)                  
        Task { await scheduleLocalBanner(for: notif) }
    }
    
    // MARK: – Local push helpers
    private func requestAuthIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
        if granted != true { print("Local‑push permission not granted") }
    }
    
    private func scheduleLocalBanner(for notif: AppNotification) async {
        let content         = UNMutableNotificationContent()
        content.title       = notif.title
        content.body        = notif.body
        content.sound       = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notif.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
