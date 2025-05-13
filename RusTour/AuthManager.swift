//
//  AuthManager.swift
//  RusTour
//
//  Created by seif on 03/03/2025.
//

import Foundation
import SwiftUI

struct User: Codable {
    let id: Int
    var firstName: String
    var lastName: String
    var email: String
    var role: String
}

final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {
        loadToken()
        if token != nil {
            Task { await loadCurrentUser() }
        }
    }

    private let baseURL = URL(string: "http://localhost:5281/api")!

    @AppStorage("jwtToken") var token: String?

    @Published var currentUser: User?
    @Published var isLoggedOut: Bool = false

    var isLoggedIn: Bool { token != nil }
    
    // MARK: — Helper to attach Bearer token
    func authorizedRequest(_ url: URL) -> URLRequest {
        var r = URLRequest(url: url)
        if let t = token {
            r.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        return r
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        let loginURL = baseURL.appendingPathComponent("Auth/login")
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let message = String(data: data, encoding: .utf8) ??
                HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: message])
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let t = json["token"] as? String {
            saveToken(t)
            await MainActor.run {
                self.token = t
                self.isLoggedOut = false
            }
            await loadCurrentUser()
            return
        }

        if let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let cleaned = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            saveToken(cleaned)
            await MainActor.run {
                self.token = cleaned
                self.isLoggedOut = false
            }
            await loadCurrentUser()
            return
        }

        throw NSError(domain: "",
                      code: 0,
                      userInfo: [NSLocalizedDescriptionKey: "Invalid login response format"])
    }
    // MARK: - Register

    func register(fullName: String, email: String, password: String) async throws {
        let registerURL = baseURL.appendingPathComponent("Auth/register")
        var request = URLRequest(url: registerURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let names = fullName.split(separator: " ", maxSplits: 1).map(String.init)
        let firstName = names.first ?? ""
        let lastName = names.count > 1 ? names[1] : ""

        let payload: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "role": "User"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let message = String(data: data, encoding: .utf8) ??
                HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            throw NSError(domain: "", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: message])
        }

        try await signIn(email: email, password: password)
        await NotificationManager.shared.post(
            title: "Добро пожаловать 👋",
            body:  "Аккаунт успешно создан!"
        )
    }
    // MARK: - Sign Out

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "jwtToken")
        DispatchQueue.main.async {
            self.token = nil
            self.currentUser = nil
            self.isLoggedOut = true
        }
    }

    private func clearSession() {
        token = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "jwtToken")
    }

    @MainActor
    func loadCurrentUser() async {
        guard let url = URL(string: "\(baseURL)/Users/me") else { return }
        do {
            let req = authorizedRequest(url)
            let (data, _) = try await URLSession.shared.data(for: req)
            currentUser   = try JSONDecoder().decode(User.self, from: data)
        } catch {
            print("Failed to load user: \(error)")
        }
    }
    
    struct UpdateUserRequest: Codable {
        let firstName: String
        let lastName:  String
        let email:     String
    }

    @MainActor
    func updateProfile(_ updated: User) async throws {
        let url = baseURL.appendingPathComponent("Users/me")
        var req = authorizedRequest(url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = UpdateUserRequest(
            firstName: updated.firstName,
            lastName:  updated.lastName,
            email:     updated.email
        )
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        if !(200...299).contains(http.statusCode) {
            let serverMsg = String(data: data, encoding: .utf8) ?? "No message"
            throw NSError(domain: "",
                          code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverMsg])
        }

        self.currentUser = updated
    }

    // MARK: - Token Persistence

    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "jwtToken")
    }

    private func loadToken() {
        token = UserDefaults.standard.string(forKey: "jwtToken")
    }
}
