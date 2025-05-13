//
//  RusTourApp.swift
//  RusTour
//
//  Created by seif on 03/03/2025.
//

import SwiftUI
import UserNotifications

@main
struct RusTourApp: App {
    @StateObject var auth = AuthManager.shared
    @StateObject var travelViewModel = RusTourViewModel()
    @StateObject var notif = NotificationManager.shared
    @StateObject var vm = RusTourViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .id(auth.token as String?)
            .environmentObject(auth)
            .environmentObject(travelViewModel)
            .environmentObject(notif)
        }
    }
}
