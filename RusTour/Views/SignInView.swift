//
//  SignInView.swift
//  RusTour
//
//  Created by seif on 10/03/2025.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingAlert: Bool = false
    @State var isLoggedIn: Bool = false
    @State private var didRegister = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Text("Log In")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 78)
            
            Spacer()
            TextInput(value: $email, isPasswordVisible: .constant(true), isPasswordField: false, placeholder: "Enter Email")
            TextInput(value: $password, isPasswordVisible: $isPasswordVisible, isPasswordField: true, placeholder: "Password")

            NavigationLink {
                ForgotPasswordView()
            } label: {
                Text("Forgot Password?")
                    .foregroundColor(Color("green"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .bold()
            }

            VStack {
                NavigationLink(destination: MainView(), isActive: $isLoggedIn) {
                    EmptyView()
                }

                Button(action: login) {
                    ButtonLabel(isDisabled: false, label: "Login")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 18)

            Text("Don't have an account?").padding(.vertical, 18)

            NavigationLink(destination: SignUpView(didRegisterSuccessfully: $didRegister)) {
                VStack {
                    Text("REGISTER")
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
        .alert("Login Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty"
            showingAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await AuthManager.shared.signIn(email: email, password: password)
                await MainActor.run {
                    isLoggedIn = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}
