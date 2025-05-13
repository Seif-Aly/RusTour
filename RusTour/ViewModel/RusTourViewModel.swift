//
//  RusTourViewModel.swift
//  RusTour
//
//  Created by seif on 03/03/2025.
//

import Foundation

struct TourDate: Identifiable, Codable, Hashable {
    let id: Int
    let tourId: Int
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id
        case tourId = "tourId"
        case date
    }
}

// MARK: — Tour Model

struct Tour: Identifiable, Codable {
    let id: Int
    let title: String
    let country: String
    let description: String
    let imageUrl: String
    let ratingValue: Double
    let ratingCount: Int
    let durationDays: Int
    let distanceKm: Int
    let temperatureC: Int
    let weatherState: String
    let pricePerAdult: Double
    let pricePerChild: Double
    let availableDates: [TourDate]?
    let rooms: [RoomType]?
    let services: [Service]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, country, description
        case imageUrl, ratingValue, ratingCount,
             durationDays, distanceKm, temperatureC, weatherState,
             pricePerAdult, pricePerChild,
             availableDates, rooms, services
    }
}

struct RoomType: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let capacity: Int
}

struct Service: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

// MARK: — Other Models

struct CountryData: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var flag: String
}

struct Tab: Identifiable {
    var id = UUID()
    var label: String
    var value: Int
}

struct TourSearchRequest: Codable {
    var city: String?
    var fromDate: String?
    var toDate: String?
    var adults: Int
    var rooms: Int
}

struct Booking: Identifiable, Codable {
    let id: Int
    let tour: Tour
    let bookingDate: Date
}

// MARK: — ViewModel

@MainActor
final class RusTourViewModel: ObservableObject {
    // country picker data
    @Published var countriesData: [CountryData] = []
    @Published var country: CountryData = CountryData(name: "", flag: "")
    @Published var myBookings: [Booking] = []

//    @Published var country: CountryData

    // your tab categories (e.g. All/America/…)
    @Published var tabs: [Tab] = []

    // Tours data
    @Published var tours: [Tour] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func setCountry(data: CountryData) {
        country = data
    }

    init() {
        // country setup
        country = CountryData(name: "", flag: "")
        countriesData = Self.getCountries()
    }

    // MARK: — Fetch All Tours

    /// Call GET /api/tours
    func loadTours() async {
        guard let url = URL(string: "http://localhost:5281/api/tours") else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let req = AuthManager.shared.authorizedRequest(url)
            let (data, _) = try await URLSession.shared.data(for: req)
            // decode dates in ISO8601
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            tours = try decoder.decode([Tour].self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: — Country Helpers

    static func getCountries() -> [CountryData] {
        var data: [CountryData] = []
        for code in NSLocale.isoCountryCodes {
            guard let flag = String.emojiFlag(for: code) else { continue }
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            if let name = NSLocale(localeIdentifier: "en_UK")
                .displayName(forKey: .identifier, value: id) {
                data.append(.init(name: name, flag: flag))
            }
        }
        return data
    }
    @MainActor
    func searchTours(criteria: TourSearchRequest) async throws -> [Tour] {
        let url = URL(string: "http://localhost:5281/api/tours/search")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(criteria)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if !(200...299).contains(http.statusCode) {
            let serverMsg = String(data: data, encoding: .utf8) ?? "No response body"
            throw NSError(
                domain: "",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: serverMsg]
            )
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Tour].self, from: data)
    }
    @MainActor
    func loadMyBookings() async {
        guard let url = URL(string: "http://localhost:5281/api/bookings/my") else { return }
        do {
            let req = AuthManager.shared.authorizedRequest(url)
            let (data, _) = try await URLSession.shared.data(for: req)

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let flex = DateFormatter()
            flex.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            flex.locale = Locale(identifier: "en_US_POSIX")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let str = try container.decode(String.self)
                if let d = iso.date(from: str) { return d }
                if let d = flex.date(from: str) { return d }
                throw DecodingError.dataCorruptedError(
                   in: container,
                   debugDescription: "Cannot parse date: \(str)"
                )
            }

            myBookings = try decoder.decode([Booking].self, from: data)
        } catch {
            print("Failed to load bookings:", error)
        }
    }


    func createBooking(for tour: Tour,
                       date: Date,
                       adults: Int,
                       children: Int,
                       roomId: Int?) async throws {
        guard let url = URL(string: "http://localhost:5281/api/bookings") else { return }
        var req = AuthManager.shared.authorizedRequest(url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "tourId": tour.id,
            "bookingDate": ISO8601DateFormatter().string(from: date)
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        NotificationManager.shared.post(
            title: "Бронирование подтверждено ✅",
            body:  "\(tour.title) — \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))"
        )
    }
}

extension String {
    static func emojiFlag(for countryCode: String) -> String? {
        let base: UInt32 = 0x1F1E6 - 0x41
        var s = ""
        for v in countryCode.uppercased().utf16 {
            guard let scalar = Unicode.Scalar(base + UInt32(v)) else { return nil }
            s.unicodeScalars.append(scalar)
        }
        return s
    }
}
