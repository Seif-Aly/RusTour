//
//  SignUpView.swift
//  RusTour
//
//  Created by seif on 10/03/2025.
//

import SwiftUI

struct SignUpView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingAlert: Bool = false
    @Binding var didRegisterSuccessfully: Bool
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Text("Регистрация")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 78)

            // Full Name
            TextInput(value: $fullName, isPasswordVisible: .constant(false), isPasswordField: false, placeholder: "Полное имя")

            // Email
            TextInput(value: $email, isPasswordVisible: .constant(false), isPasswordField: false, placeholder: "Введите электронную почту")

            // Password
            TextInput(value: $password, isPasswordVisible: $isPasswordVisible, isPasswordField: true, placeholder: "Пароль")

            // Confirm Password
            TextInput(value: $confirmPassword, isPasswordVisible: $isConfirmPasswordVisible, isPasswordField: true, placeholder: "Подтвердите пароль")

//            VStack {
//                NavigationLink(destination: MainView(), isActive: $didRegisterSuccessfully) {
//                    EmptyView()
//                }
//                Button(action: register) {
//                    ButtonLabel(isDisabled: false, label: "Register")
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .padding(.vertical, 18)
            Button(action: register) {
                ButtonLabel(isDisabled: false, label: "Регистрация")
            }
            .padding(.vertical, 18)

            Text("Уже есть аккаунт?").padding(.vertical, 18)

            NavigationLink(destination: SignInView()) {
                VStack {
                    Text("ВОЙТИ")
                        .tracking(4)
                        .foregroundColor(Color("green"))
                        .padding(.bottom, 2)
                    Rectangle()
                        .frame(width: 26, height: 1)
                        .foregroundColor(Color("green"))
                }
            }
        }
        .ignoresSafeArea()
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .background(Color(.secondarySystemBackground))
        .alert("Ошибка регистрации", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    func register() {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Все поля обязательны для заполнения"
            showingAlert = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            showingAlert = true
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await AuthManager.shared.register(fullName: fullName, email: email, password: password)
//                await MainActor.run {
//                    didRegisterSuccessfully = true
//                }
                await MainActor.run { dismiss() }
            } catch {
                errorMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(didRegisterSuccessfully: .constant(false))
            .environmentObject(AuthManager.shared)
    }
}
