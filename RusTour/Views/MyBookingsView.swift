//
//  MyBookingsView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject private var vm: RusTourViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }

                Text("Мои бронирования")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()

            if vm.myBookings.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List(vm.myBookings) { booking in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: booking.tour.imageUrl)) { phase in
                            if let img = phase.image {
                                img.resizable()
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(booking.tour.title).bold()
                            Text(booking.bookingDate, format: .dateTime.day().month().year())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(true)

        .task { await vm.loadMyBookings() }
    }
}
