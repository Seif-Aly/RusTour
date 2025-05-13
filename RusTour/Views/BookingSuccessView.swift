//
//  BookingSuccessView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct BookingSuccessView: View {
    @EnvironmentObject private var vm: RusTourViewModel
    @State private var goToMain = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.green)

            Text("Бронирование успешно!")
                .font(.title2)
                .bold()

            Button("На главную") {
                goToMain = true
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .buttonStyle(.borderedProminent)
            .tint(Color("green"))

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        // «Фоновый» NavigationLink, чтобы сразу перейти в MainView и увидеть таб‑бар
        .background(
            NavigationLink(
                destination: MainView()
                    .environmentObject(vm)
                    .navigationBarHidden(true),
                isActive: $goToMain,
                label: { EmptyView() }
            )
            .hidden()
        )
    }
}
