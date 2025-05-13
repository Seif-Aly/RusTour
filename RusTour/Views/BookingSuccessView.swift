//
//  BookingSuccessView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct BookingSuccessView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .resizable().frame(width: 120, height: 120)
                .foregroundColor(.green)

            Text("Бронирование успешно!")
                .font(.title2).bold()

            NavigationLink("К моим бронированиям") {
                MyBookingsView()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("green"))
        }
        .navigationBarBackButtonHidden(true)
    }
}
