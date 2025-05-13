//
//  SearchResultsView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct SearchResultsView: View {
    let criteria: TourSearchRequest

    @State private var tours:   [Tour] = []
    @State private var loading: Bool   = true
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var viewModel: RusTourViewModel
    @Namespace private var animation

    var body: some View {
        VStack(spacing: 0) {
            header
            resultsScroll
        }
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .task {
            do {
                tours = try await viewModel.searchTours(criteria: criteria)
            } catch {
                print("Search failed:", error.localizedDescription)
                tours = []
            }
            loading = false
        }
    }

    // MARK: – UI Parts
    private var header: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.primary)
            }
            Text("Туры")
                .font(.title3).bold()
                .frame(maxWidth: .infinity)
                .offset(x: -10)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    private var resultsScroll: some View {
        ScrollView {
            if loading {
                ProgressView("Загрузка…")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 80)
            } else if tours.isEmpty {
                Text("Туры не найдены")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 80)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(tours) { tour in
                        NavigationLink {
                            LocationView(tour: tour, animation: animation)
                        } label: {
                            TourCardSmall(tour: tour)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

// ───────────────────────────────────────────────────────────────────
// Small vertical card reused in the list
struct TourCardSmall: View {
    let tour: Tour

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: tour.imageUrl)) { phase in
                if let img = phase.image {
                    img.resizable()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: 140)
            .clipped()
            .cornerRadius(16)

            HStack {
                Text(tour.title)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("$\(tour.pricePerAdult, format: .number.grouping(.never))")
                    .font(.headline)
            }
            .padding(.top, 10)
            .padding(.bottom, 8)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
                    .font(.footnote)
                Text(String(format: "%.1f", tour.ratingValue))
                    .foregroundColor(.white)
                Text("(\(tour.ratingCount))")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("/ per tour")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(6)
            .background(Color("green"))
            .cornerRadius(12)
        }
        .padding(.bottom, 32)
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(criteria: .init(city: "Paris",
                                          fromDate: nil,
                                          toDate: nil,
                                          adults: 2,
                                          rooms: 1))
            .environmentObject(RusTourViewModel())
    }
}
