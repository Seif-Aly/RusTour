//
//  PaymentView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct PaymentView: View {
    let tour: Tour

    // MARK: – State
    @State private var selectedDate: Date
    @State private var selectedRoomIndex: Int = 0
    @State private var adultCount: Int = 1
    @State private var childCount: Int = 0
    @State private var selectedExtras: Set<Int> = []

    // initialize our date picker to the first available date (or today)
    init(tour: Tour) {
        self.tour = tour
        _selectedDate = State(initialValue: tour.availableDates?.first?.date ?? Date())
    }

    // MARK: – Computed total
    private var total: Double {
        Double(adultCount) * tour.pricePerAdult
          + Double(childCount) * tour.pricePerChild
    }

    var body: some View {
        Form {
            // ─── Tour Header ─────────────────────────────────
            Section {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tour.title)
                            .font(.headline)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.subheadline)
                            Text(String(format: "%.1f", tour.ratingValue))
                                .font(.subheadline)
                            Text("(\(tour.ratingCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            // ─── Date Picker ─────────────────────────────────
            Section("Select Date") {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }

            // ─── Room Type ──────────────────────────────────
            if let rooms = tour.rooms, !rooms.isEmpty {
                Section("Room Type") {
                    Picker("Room", selection: $selectedRoomIndex) {
                        ForEach(Array(rooms.enumerated()), id: \.offset) { idx, room in
                            Text("\(room.name) (up to \(room.capacity))")
                                .tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            // ─── Guests ─────────────────────────────────────
            Section("Guests") {
                Stepper("Adults: \(adultCount)", value: $adultCount, in: 1...10)
                Stepper("Children: \(childCount)", value: $childCount, in: 0...10)
            }

            // ─── Extras ─────────────────────────────────────
            if let services = tour.services, !services.isEmpty {
                Section("Extras") {
                    ForEach(services) { extra in
                        Toggle(extra.name,
                               isOn: Binding(
                                   get: { selectedExtras.contains(extra.id) },
                                   set: { isOn in
                                       if isOn {
                                           selectedExtras.insert(extra.id)
                                       } else {
                                           selectedExtras.remove(extra.id)
                                       }
                                   }
                               ))
                    }
                }
            }

            // ─── Total & Pay Button ─────────────────────────
            Section(footer:
                        HStack {
                            Text("Total:")
                            Spacer()
                            Text("$\(total, format: .number.grouping(.never))")
                                .bold()
                                .foregroundColor(Color("green"))
                        }
                        .font(.title3)
            ) {
                Button("Confirm & Pay") {
                    // TODO: trigger your payment flow with:
                    // selectedDate, rooms?[selectedRoomIndex], adultCount, childCount, selectedExtras
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("green"))
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
    }
}
