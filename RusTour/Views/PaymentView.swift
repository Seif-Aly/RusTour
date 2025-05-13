//
//  PaymentView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct PaymentView: View {
    let tour: Tour

    // MARK: – State
    @State private var selectedDate: Date
    @State private var selectedRoomIndex: Int = 0
    @State private var adultCount = 1
    @State private var childCount  = 0
    @State private var selectedExtras: Set<Int> = []
    @EnvironmentObject private var vm: RusTourViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitting   = false
    @State private var showingSuccess = false

    private var startDates: [Date] {
        tour.availableDates?.map(\.date).sorted() ?? []
    }
    private var checkOutDate: Date {
        Calendar.current.date(byAdding: .day,
                              value: tour.durationDays,
                              to: selectedDate) ?? selectedDate
    }

    init(tour: Tour) {
        self.tour = tour
        _selectedDate = State(initialValue: tour.availableDates?.first?.date ?? Date())
    }

    private var total: Double {
        Double(adultCount) * tour.pricePerAdult +
        Double(childCount) * tour.pricePerChild
    }

    // MARK: – Body
    var body: some View {
        Form {
            headerSection

            Section("Дата начала") {
                Picker("Дата", selection: $selectedDate) {
                    ForEach(startDates, id: \.self) { d in
                        Text(d.formatted(.dateTime.day().month().year()))
                            .tag(d)
                    }
                }
            }

            Section {
                HStack {
                    Text("Дата окончания:")
                    Spacer()
                    Text(checkOutDate.formatted(.dateTime.day().month().year()))
                        .bold()
                }
            }

            if let rooms = tour.rooms, !rooms.isEmpty {
                Section("Тип номера") {
                    Picker("Номер", selection: $selectedRoomIndex) {
                        ForEach(Array(rooms.enumerated()), id: \.offset) { idx, room in
                            Text("\(room.name) (до \(room.capacity))").tag(idx)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Гости") {
                Stepper("Взрослые: \(adultCount)", value: $adultCount, in: 1...10)
                Stepper("Дети: \(childCount)",    value: $childCount, in: 0...10)
            }

            if let services = tour.services, !services.isEmpty {
                Section("Дополнительные услуги") {
                    ForEach(services) { svc in
                        Toggle(svc.name,
                               isOn: Binding(
                                   get: { selectedExtras.contains(svc.id) },
                                   set: { isOn in
                                       if isOn { selectedExtras.insert(svc.id) }
                                       else     { selectedExtras.remove(svc.id) }
                                   }))
                    }
                }
            }

            paySection
        }
        .navigationTitle("Оплата")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: – Sub‑views

    private var headerSection: some View {
        Section {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                    if let img = phase.image { img.resizable() }
                    else { Color.gray.opacity(0.2) }
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tour.title).font(.headline)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", tour.ratingValue))
                        Text("(\(tour.ratingCount))")
                            .font(.caption).foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private var paySection: some View {
        Section(
            footer: HStack {
                Text("Итого:")
                Spacer()
                Text("$\(total, format: .number.grouping(.never))")
                    .bold().foregroundColor(Color("green"))
            }.font(.title3)
        ) {
            NavigationLink {
                BookingSuccessView()
                    .task {
                        await sendBooking()
                    }
            } label: {
                Text("Подтвердить и оплатить")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("green"))
        }
    }

    // MARK: – Network call
    @MainActor
    private func sendBooking() async {
        do {
            let roomId: Int? = {
                guard let rooms = tour.rooms,
                      rooms.indices.contains(selectedRoomIndex)
                else { return nil }
                return rooms[selectedRoomIndex].id
            }()

            try await RusTourViewModel().createBooking(
                for: tour,
                date: selectedDate,
                adults: adultCount,
                children: childCount,
                roomId: roomId
            )
        } catch {
            print("Booking failed:", error)
        }
    }

}
