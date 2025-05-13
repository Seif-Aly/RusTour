//
//  SearchView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var date = Date()
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date()
    @State private var cityName: String = "";
    @State private var numberOfAdults: Int = 1;
    @State private var numberOfRooms: Int = 1;
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>;
    
    var body: some View {
        VStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                BackButtonLabel()
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        VStack(spacing: 0) {
            HStack {
                Text("Поиск туров")
                    .bold()
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("green"))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 54)
            .frame(maxWidth: .infinity)
            
            Text("Город")
                .padding(.leading, 16)
                .padding(.bottom, 12)
                .foregroundColor(Color("accent").opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(Color("accent"))
                
                TextField("Введите название города", text: $cityName)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color("lightpurple")))
            .padding(.horizontal, 12)
            .padding(.bottom, 32)
            .cornerRadius(12)
            
            
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("Дата начала")
                        .padding(.leading, 16)
                        .padding(.bottom, 2)
                        .foregroundColor(Color("accent").opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack {
                        DatePicker("label", selection: $checkInDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                        HStack(spacing: 0) {
                            Image(systemName: "calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(Color("accent"))
                            
                            Text("\(checkInDate.formatted(.dateTime.weekday(.abbreviated))), \(checkInDate.formatted(.dateTime.day())) \(checkInDate.formatted(.dateTime.month(.abbreviated)))")
                                .padding(.leading, 14)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 46)
                        .background(Color("lightpurple"))
                        //                        .background(.red)
                        .cornerRadius(12)
                        .userInteractionDisabled()
                    }
                    
                }
                .frame(maxHeight: 90)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Дата окончания")
                        .padding(.leading, 16)
                        .padding(.bottom, 2)
                        .foregroundColor(Color("accent").opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack {
                        DatePicker("label", selection: $checkOutDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .background(.purple)
                            .padding(0)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(Color("accent"))
                            
                            Text("\(checkOutDate.formatted(.dateTime.weekday(.abbreviated))), \(checkOutDate.formatted(.dateTime.day())) \(checkOutDate.formatted(.dateTime.month(.abbreviated)))")
                                .padding(.leading, 14)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 46)
                        .background(Color("lightpurple"))
                        .cornerRadius(12)
                        .userInteractionDisabled()
                    }
                }
                .frame(maxHeight: 90)
            }
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    Text("Детали гостей")
                        .padding(.leading, 16)
                        .padding(.bottom, 12)
                        .foregroundColor(Color("accent").opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Menu {
                        ForEach(1...5, id: \.self) {item in
                            
                            Button {
                                numberOfAdults = item
                            } label: {
                                Text("\(item == 1 ? "1 Взрослый" : "\(item) Взрослые")")
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color("accent"))
                                .frame(width: 22, height: 22)
                            
                            Text("\(numberOfAdults == 1 ? "1 Взрослый" : "\(numberOfAdults) Взрослые")")
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(Color("lightpurple")))
                        .padding(.horizontal, 12)
                        .padding(.bottom, 32)
                        .cornerRadius(12)
                    }
                    
                }
                
                VStack(spacing: 0) {
                    Text("Комната")
                        .padding(.leading, 16)
                        .padding(.bottom, 12)
                        .foregroundColor(Color("accent").opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        
                        Button {
                            numberOfRooms = numberOfRooms == 0 ? 0 : numberOfRooms - 1
                        } label: {
                            Image(systemName: "minus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: 12, height: 12)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(Color("accent").opacity(0.8), lineWidth: 1))
                        }
                        .disabled(numberOfRooms == 0)
                        
                        
                        Text("\(numberOfRooms)")
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            numberOfRooms+=1
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(width: 12, height: 12)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(Color("accent").opacity(0.8), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxHeight: 46)
                }
                
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            VStack {
                
                NavigationLink {
                    SearchResultsView(criteria: TourSearchRequest(
                        city: cityName.isEmpty ? nil : cityName,
                        fromDate:   isoDate(checkInDate),
                        toDate:  isoDate(checkOutDate),
                        adults:        numberOfAdults,
                        rooms:         numberOfRooms
                    ))
                } label: {
                    ButtonLabel(isDisabled: false, label: "Поиск")
                }

            }
            .padding(.bottom, 12)
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 12)
        .navigationBarBackButtonHidden()
        .navigationBarHidden(false)
        //        .ignoresSafeArea()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

struct NoHitTesting: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

private func isoDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    return df.string(from: date)
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(NoHitTesting())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
