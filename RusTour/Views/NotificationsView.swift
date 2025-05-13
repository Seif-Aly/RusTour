//
//  NotificationView.swift
//  RusTour
//
//  Created by seif on 23/04/2025.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var notif: NotificationManager
    @Environment(\.presentationMode) private var presentation

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Уведомления")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding([.horizontal, .top], 16)

            if notif.items.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Пока уведомлений нет")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                List(notif.items) { n in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(n.title).bold()
                        Text(n.body)
                            .foregroundColor(.secondary)
                        Text(n.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationBarHidden(true)
    }
}
