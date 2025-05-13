//
//  LocationView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct LocationView: View {
    let tour: Tour
    var animation: Namespace.ID

    @Environment(\.presentationMode) private var presentation
    @State private var selectedTab = 0

    @Environment(\.safeAreaInsets) private var safeAreaInsets
    private var safeAreaTop: CGFloat { safeAreaInsets.top }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // MARK: – Main Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // HEADER IMAGE (fixed height, full width)
                        AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height * 0.40)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.12), .clear]),
                                startPoint: .top, endPoint: .bottom
                            )
                        )

                        // CONTENT CARD (overlapping header)
                        VStack(alignment: .leading, spacing: 16) {
                            // Title & price
                            HStack(alignment: .top) {
                                Text(tour.title)
                                    .font(.title2).bold()
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer()

                                Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                                    .font(.headline).bold()
                                    .foregroundColor(Color("green"))
                            }

                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").foregroundColor(.yellow)
                                Text("\(tour.ratingValue, specifier: "%.1f") (\(tour.ratingCount))")
                                    .foregroundColor(.gray)
                                Spacer()
                            }

                            // Segment picker
                            Picker("", selection: $selectedTab) {
                                Text("Обзор").tag(0)
                                Text("Подробности").tag(1)
                            }
                            .pickerStyle(.segmented)

                            // Content
                            if selectedTab == 0 {
                                overviewSection
                            } else {
                                detailsSection
                            }

                            // Footer buttons
                            footerButtons
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .offset(y: -40)
                        .frame(width: geo.size.width)
                        .padding(.bottom, 40)
                    }
                    .frame(width: geo.size.width)
                }
                .ignoresSafeArea(edges: .top)

                // MARK: – Back Button
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                        )
                }
                .padding(.top, safeAreaTop + 8)
                .padding(.leading, 16)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // MARK: – Overview
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tour.description)
                .foregroundColor(.gray)
            infoRow(icon: "clock.fill",
                    value: "\(tour.durationDays) Days",
                    subtitle: "Продолжительность")
            infoRow(icon: "mappin.circle.fill",
                    value: "\(tour.distanceKm) KM",
                    subtitle: "Расстояние")
            infoRow(icon: "sun.max.circle.fill",
                    value: "\(tour.temperatureC)°C",
                    subtitle: tour.weatherState)
        }
    }

    // MARK: – Details
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                pricePill(title: "Взрослый", amount: tour.pricePerAdult)
                pricePill(title: "Ребёнок",  amount: tour.pricePerChild)
            }
            .padding(.vertical, 8)
            .background(Color("green").opacity(0.1))
            .cornerRadius(12)

            Text("Доступные даты").font(.headline)
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

            if let rooms = tour.rooms, !rooms.isEmpty {
                Text("Типы комнат").font(.headline)
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

            if let services = tour.services, !services.isEmpty {
                Text("Услуги").font(.headline)
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
    }

    // MARK: – Helpers

    private func pricePill(title: String, amount: Double) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(.gray)
            Text("$\(amount, format: .number.grouping(.never))")
                .font(.headline).bold()
                .foregroundColor(Color("green"))
        }
        .frame(maxWidth: .infinity)
    }

    private var footerButtons: some View {
        HStack(spacing: 16) {
            Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                .font(.headline)
                .foregroundColor(Color("green"))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color("green"), lineWidth: 2)
                )

            NavigationLink {
                PaymentView(tour: tour)
            } label: {
                Text("Забронировать")
                    .font(.headline).bold()
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("green"))
        }
        .padding(.top, 8)
    }

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
