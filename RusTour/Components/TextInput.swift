//
//  TextInput.swift
//  RusTour
//
//  Created by seif on 03/03/2025.
//

import SwiftUI

struct TextInput: View {
    @Binding var value: String
    @Binding var isPasswordVisible: Bool
    var isPasswordField: Bool = true
    var placeholder: String
    var isPhoneNumberField: Bool = false

    @EnvironmentObject private var viewModel: RusTourViewModel

    var body: some View {
        HStack {
            if isPhoneNumberField {
                HStack(spacing: 8) {
                    // Country selector menu
                    Menu {
                        ForEach(viewModel.countriesData) { item in
                            Button {
                                viewModel.setCountry(data: item)
                            } label: {
                                HStack {
                                    Text(item.name)
                                    Text(item.flag)
                                }
                            }
                        }
                    } label: {
                        Text(viewModel.country.flag)
                            .font(.title)
                    }

                    // Divider
                    Rectangle()
                        .frame(width: 1, height: 34)
                        .foregroundColor(Color("darkgrey"))
                }
            }

            // Text / Secure Field
            if isPasswordField {
                if isPasswordVisible {
                    TextField("", text: $value)
                        .modifier(PlaceholderStyle(showPlaceHolder: value.isEmpty,
                                                  placeholder: placeholder))
                } else {
                    SecureField("", text: $value)
                        .modifier(PlaceholderStyle(showPlaceHolder: value.isEmpty,
                                                  placeholder: placeholder))
                }
            } else {
                TextField("", text: $value)
                    .modifier(PlaceholderStyle(showPlaceHolder: value.isEmpty,
                                              placeholder: placeholder))
            }

            // Toggle visibility button
            if isPasswordField {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color("darkgrey"))
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 57)
        .background(Color.white)
        .cornerRadius(15)
        .padding(.bottom, 12)
    }
}

// Placeholder modifier remains unchanged
public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .padding(.horizontal, 4)
                    .foregroundColor(Color("darkgrey"))
            }
            content
                .foregroundColor(Color.primary)
                .padding(5)
        }
    }
}

struct TextInput_Previews: PreviewProvider {
    static var previews: some View {
        TextInput(value: .constant(""),
                  isPasswordVisible: .constant(false),
                  isPasswordField: false,
                  placeholder: "Enter number",
                  isPhoneNumberField: true)
            .environmentObject(RusTourViewModel())
            .padding(.horizontal, 24)
            .frame(height: 200)
            .background(Color.gray.opacity(0.2))
    }
}
