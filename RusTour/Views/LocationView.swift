//
//  LocationView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct LocationView: View {
    let tour: Tour                // injected from HomeView
    var animation: Namespace.ID

    @Environment(\.presentationMode) private var presentation
    @State private var selectedTab = 0   // 0 = Overview, 1 = Details

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                headerImage(in: geo.size)
                contentCard(in: geo.size)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .edgesIgnoringSafeArea(.top)

            // Back button
//            Button {
//                presentation.wrappedValue.dismiss()
//            } label: {
//                Image(systemName: "chevron.left")
//                    .font(.title3.weight(.semibold))
//                    .foregroundColor(.primary)
//                    .padding(12)
//                    .background(.ultraThinMaterial, in: Circle())
//            }
//            .padding(.leading, 20)
//            .padding(.top, 44)  // adjust if needed for notch
        }
    }

    // MARK: — Header Image (40% height)
    private func headerImage(in fullSize: CGSize) -> some View {
        AsyncImage(url: URL(string: tour.imageUrl)) { phase in
            if let img = phase.image {
                img.resizable().scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: fullSize.width,
               height: fullSize.height * 0.40)
        .clipped()
    }

    // MARK: — Content Card (60% height)
    private func contentCard(in fullSize: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title & price
            HStack(alignment: .top) {
                Text(tour.title)
                    .font(.title2).bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                    .font(.headline)     // slightly smaller
                    .bold()
                    .foregroundColor(Color("green"))
            }

            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(tour.ratingValue, specifier: "%.1f") (\(tour.ratingCount))")
                    .foregroundColor(.gray)
                Spacer()
            }

            // Segment picker
            Picker("", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Details").tag(1)
            }
            .pickerStyle(.segmented)

            // Content
            Group {
                if selectedTab == 0 {
                    overviewSection
                } else {
                    ScrollView(showsIndicators: false) {
                        detailsSection
                    }
                }
            }

            // Footer buttons
            footerButtons
        }
        .padding(24)
        .frame(width: fullSize.width,
               height: fullSize.height * 0.60,
               alignment: .top)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .offset(y: -40) // lift up to overlap header
    }

    // MARK: — Overview
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tour.description)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)

            infoRow(icon: "clock.fill",
                    value: "\(tour.durationDays) Days",
                    subtitle: "Duration")

            infoRow(icon: "mappin.circle.fill",
                    value: "\(tour.distanceKm) KM",
                    subtitle: "Distance")

            infoRow(icon: "sun.max.circle.fill",
                    value: "\(tour.temperatureC)°C",
                    subtitle: tour.weatherState)
        }
    }

    // MARK: — Details
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ── Prices Card ───────────────────────────────────────────
            HStack(spacing: 16) {
                pricePill(title: "Adult", amount: tour.pricePerAdult)
                pricePill(title: "Child", amount: tour.pricePerChild)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color("green").opacity(0.1))
            .cornerRadius(12)

            // ── Available Dates ───────────────────────────────────────
            Text("Available Dates")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tour.availableDates ?? []) { td in
                        Text(td.date, style: .date)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }

            // ── Rooms ────────────────────────────────────────────────
            if let rooms = tour.rooms, !rooms.isEmpty {
                Text("Rooms")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(rooms) { room in
                        Text(room.name)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }

            // ── Services ─────────────────────────────────────────────
            if let services = tour.services, !services.isEmpty {
                Text("Services")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(services) { svc in
                        Text(svc.name)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: – Helpers

    private func pricePill(title: String, amount: Double) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text("$\(amount, format: .number.grouping(.never))")
                .font(.headline)
                .bold()
                .foregroundColor(Color("green"))
        }
        .frame(maxWidth: .infinity)
    }


    // MARK: — Footer Buttons
    private var footerButtons: some View {
        HStack(spacing: 16) {
            // Price smaller
            Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                .font(.headline)
                .foregroundColor(Color("green"))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("green"), lineWidth: 2)
                )

            // Book now bigger
            NavigationLink {
                PaymentView(tour: tour)
            } label: {
                Text("Book now")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("green"))
        }
        .padding(.top, 8)
    }

    // MARK: — Helper Row
    @ViewBuilder
    private func infoRow(icon: String,
                         value: String,
                         subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(value).bold()
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
