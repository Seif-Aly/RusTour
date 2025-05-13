//
//  HomeView.swift
//  RusTour
//
//  Created by seif on 06/04/2025.
//

import SwiftUI

struct Category: Identifiable {
    var id = UUID()
    var label: String
    var value: Int
    var image: String
}

struct HomeView: View {
    @State private var selectedCity: String = "All"
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: RusTourViewModel
    @Namespace private var animation

    private let categories: [Category] = [
        .init(label: "Trips",     value: 0, image: "category_trips"),
        .init(label: "Hotel",     value: 1, image: "category_hotel"),
        .init(label: "Transport", value: 2, image: "category_transport"),
        .init(label: "Events",    value: 3, image: "category_events"),
    ]

    private var categorySize: CGFloat { ((UIScreen.main.bounds.width - 48) / 4) * 0.55 }
    private var slideSize:    CGFloat { (UIScreen.main.bounds.width - 48) * 0.6 }

    private var cityTabs: [String] {
        let cities = viewModel.tours.map { $0.city }
        let unique = Array(Set(cities)).sorted()
        return ["All"] + unique
    }

    private var filteredTours: [Tour] {
        guard selectedCity != "All" else { return viewModel.tours }
        return viewModel.tours.filter { $0.city == selectedCity }
    }

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {

                // MARK: – Top Bar
                HStack {
                    Button { } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Rectangle().frame(width: 22, height: 2.5).foregroundColor(.primary)
                            Rectangle().frame(width: 16, height: 2.5).foregroundColor(.primary)
                        }
                    }
                    Spacer()
                    Button { } label: {
                        Image(systemName: "bell")
                            .resizable().scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // MARK: – Title
                Text("Where Do You\nWant To Go?")
                    .font(.largeTitle).bold()
                    .foregroundColor(.primary)
                    .lineSpacing(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                // MARK: – Search Bar
                NavigationLink(destination: SearchView()) {
                    HStack {
                        Text("Search your trip")
                            .foregroundColor(colorScheme == .dark
                                             ? .white.opacity(0.5)
                                             : .black.opacity(0.5))
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(12)
                            .background(Color("green"))
                            .cornerRadius(30)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(60)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }

                // MARK: – City Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(cityTabs, id: \.self) { city in
                            Button {
                                selectedCity = city
                            } label: {
                                VStack(spacing: 4) {
                                    Text(city)
                                        .font(.subheadline).bold()
                                        .foregroundColor(selectedCity == city
                                                         ? Color("green")
                                                         : Color("darkgrey"))
                                    Circle()
                                        .fill(selectedCity == city
                                              ? Color("green")
                                              : Color.clear)
                                        .frame(width: 6, height: 6)
                                        .animation(.easeInOut, value: selectedCity)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // MARK: – Tours Carousel
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading tours…")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                ForEach(Array(filteredTours.enumerated()), id: \.element.id) { index, tour in
                                    tourCard(
                                        for: tour,
                                        isFirst: index == 0,
                                        isLast: index == filteredTours.count - 1
                                    )
                                }
                            }
                        }
                    }
                }

                // MARK: – Categories
                Text("Popular Categories")
                    .font(.headline).bold()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                HStack(spacing: categorySize * 0.5) {
                    ForEach(categories) { category in
                        Button {
                            // category filter
                        } label: {
                            VStack {
                                Image(category.image)
                                    .resizable().scaledToFill()
                                    .frame(width: categorySize, height: categorySize)
                                Text(category.label)
                                    .font(.subheadline)
                                    .foregroundColor(Color("darkgrey"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
        }
        .task {
            if viewModel.tours.isEmpty {
                await viewModel.loadTours()
            }
        }
    }

    // MARK: – Single Tour Card (extracted to help compiler)
    @ViewBuilder
    private func tourCard(for tour: Tour, isFirst: Bool, isLast: Bool) -> some View {
        NavigationLink {
            LocationView(tour: tour, animation: animation)
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                    if let img = phase.image {
                        img.resizable()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .scaledToFill()
                .frame(width: slideSize, height: slideSize * 1.3)
                .clipped()
                .cornerRadius(24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tour.title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("From $\(tour.pricePerAdult, format: .number.grouping(.never))")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: slideSize - 32)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .padding(.leading, isFirst ? 24 : 0)
            .padding(.trailing, isLast ? 24 : 0)
        }
    }
}

// MARK: – Tour extension to extract a “city” from title
private extension Tour {
    var city: String {
        return title
            .components(separatedBy: CharacterSet(charactersIn: " ,–&"))
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? country
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(RusTourViewModel())
    }
}
