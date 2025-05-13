//
//  ProfileView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager
    
    

    @State private var editing = false
    @State private var draft: User = .init(id: 0,
                                           firstName: "",
                                           lastName: "",
                                           email: "",
                                           role: "User")

    var body: some View {
        VStack {
            // MARK: – Top Bar
            HStack(spacing: 0) {
                Text("Профиль")
                    .bold()
                    .font(.title3)
                    .padding(.leading, 18)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: – Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Avatar via ui-avatars.com
                    AsyncImage(url: URL(string:
                        "https://ui-avatars.com/api/?name=\(auth.currentUser?.firstName ?? "")+\(auth.currentUser?.lastName ?? "")&background=0D8ABC&color=fff")
                    ) { phase in
                        if let img = phase.image {
                            img.resizable()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())

                    // Status dot
                    Circle()
                        .frame(width: 18, height: 18)
                        .foregroundColor(Color("green"))
                        .overlay(
                            Circle()
                                .stroke(Color(.secondarySystemBackground), lineWidth: 4)
                                .frame(width: 20, height: 20)
                        )
                        .offset(x: 46, y: -38)
                }
                .padding(.top, 32)

                // Name
                Text("\(auth.currentUser?.firstName ?? "") \(auth.currentUser?.lastName ?? "")")
                    .font(.title)
                    .bold()

                // ID
                if let id = auth.currentUser?.id {
                    Text("ID : \(id)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.gray.opacity(0.8))
                }



                // Action buttons
                Button { editing = true } label: {
                    SettingItem(iconName: "settings",
                                label: "Редактировать профиль",
                                hasChevronIcon: true,
                                isSecurity: false)
                }
                NavigationLink {
                    MyBookingsView()
                } label: {
                    SettingItem(iconName: "calendar",
                                label: "Мои бронирования",
                                hasChevronIcon: true,
                                isSecurity: false)
                }
                Button {
                    auth.signOut()
                } label: {
                    SettingItem(iconName: "logout",
                                label: "Выйти",
                                hasChevronIcon: false,
                                isSecurity: false)
                }

                Spacer().frame(height: 100)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            // ensure we have the latest user
            Task { await auth.loadCurrentUser() }
        }
        // edit-profile sheet
        .sheet(isPresented: $editing) {
            EditProfileSheet(draft: $draft,
                             original: auth.currentUser ?? draft) { updated in
                Task {
                    do {
                        try await auth.updateProfile(updated)
                    } catch {
                        print("Failed to save profile: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: – Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: User
    var original: User
    var onSave: (User) -> Void
    
    private var hasChanges: Bool {
        draft.firstName != original.firstName ||
        draft.lastName  != original.lastName  ||
        draft.email     != original.email
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Имя", text: $draft.firstName)
                    TextField("Фамилия", text: $draft.lastName)
                    TextField("почта", text: $draft.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Редактировать профиль")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(!hasChanges)
                }
            }
            .onAppear { draft = original }
        }
    }
}

// MARK: – SettingItem

struct SettingItem: View {
    var iconName: String
    var label: String
    var hasChevronIcon: Bool
    var isSecurity: Bool

    var body: some View {
        HStack(alignment: isSecurity ? .top : .center, spacing: 0) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .padding(.top, isSecurity ? 2 : 0)

            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.title3)
                    .foregroundColor(.primary)

                if isSecurity {
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, maxHeight: 10)
                            .padding(.vertical, 20)
                            .foregroundColor(Color("green").opacity(0.3))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("green"))
                                    .frame(maxWidth: 65, maxHeight: 10, alignment: .leading)
                            }
                        Text("Intermediate")
                            .font(.body)
                            .bold()
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 48)
                }
            }
            .padding(.leading, 18)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            if hasChevronIcon {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
                    .padding(.top, isSecurity ? 8 : 0)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthManager.shared)
    }
}
