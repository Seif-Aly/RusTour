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
            Text("Register")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 78)

            // Full Name
            TextInput(value: $fullName, isPasswordVisible: .constant(false), isPasswordField: false, placeholder: "Full Name")

            // Email
            TextInput(value: $email, isPasswordVisible: .constant(false), isPasswordField: false, placeholder: "Enter Email")

            // Password
            TextInput(value: $password, isPasswordVisible: $isPasswordVisible, isPasswordField: true, placeholder: "Password")

            // Confirm Password
            TextInput(value: $confirmPassword, isPasswordVisible: $isConfirmPasswordVisible, isPasswordField: true, placeholder: "Confirm Password")

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
                ButtonLabel(isDisabled: false, label: "Register")
            }
            .padding(.vertical, 18)

            Text("Already have an account?").padding(.vertical, 18)

            NavigationLink(destination: SignInView()) {
                VStack {
                    Text("LOGIN")
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
        .alert("Registration Error", isPresented: $showingAlert) {
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
            errorMessage = "All fields are required."
            showingAlert = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
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
