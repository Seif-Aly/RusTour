//
//  ExploreView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var viewModel: RusTourViewModel
    @Namespace private var animation

    // MARK: — State
    @State private var selectedCity: String = "Все"

    // MARK: — Layout helpers
    private var slideSize: CGFloat {
        (UIScreen.main.bounds.width - 16*2 - 16) * 0.48
    }

    // MARK: — City tabs 
    private var cityTabs: [String] {
        let cities = viewModel.tours.map { $0.city }
        let unique = Array(Set(cities)).sorted()
        return ["Все"] + unique
    }

    // MARK: — Filtered tours
    private var filteredTours: [Tour] {
        guard selectedCity != "Все" else { return viewModel.tours }
        return viewModel.tours.filter { $0.city == selectedCity }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text("Исследовать")
                    .font(.title).bold()
                    .padding(.horizontal, 16)

                // City Tabs (HomeView style)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(cityTabs, id: \.self) { city in
                            Button {
                                selectedCity = city
                            } label: {
                                VStack(spacing: 4) {
                                    Text(city)
                                        .font(.subheadline).bold()
                                        .foregroundColor(
                                            selectedCity == city
                                            ? Color("green")
                                            : Color("darkgrey")
                                        )
                                    Circle()
                                        .fill(
                                            selectedCity == city
                                            ? Color("green")
                                            : Color.clear
                                        )
                                        .frame(width: 6, height: 6)
                                        .animation(.easeInOut, value: selectedCity)
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Tours Grid
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: slideSize), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(filteredTours) { tour in
                        NavigationLink {
                            LocationView(tour: tour, animation: animation)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                                    if let img = phase.image {
                                        img.resizable().scaledToFill()
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .frame(width: slideSize, height: slideSize * 1.2)
                                .clipped()
                                .cornerRadius(16)

                                Text(tour.title)
                                    .font(.headline)
                                    .lineLimit(2)

                                Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                                    .font(.subheadline)
                                    .foregroundColor(Color("green"))
                            }
                            .frame(width: slideSize)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
            .task {
                if viewModel.tours.isEmpty {
                    await viewModel.loadTours()
                }
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(RusTourViewModel())
    }
}
