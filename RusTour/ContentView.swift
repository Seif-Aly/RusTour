//
//  ContentView.swift
//  RusTour
//
//  Created by seif on 03/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if auth.token != nil {
                MainView()
            } else {
                SignInView()
            }
        }
    }
}
