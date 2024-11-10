//
//  ErrorMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ErrorMessageView: View {
    @Binding var message: String
    
    var body: some View {
        if !message.isEmpty {
            HStack {
                Text(message)
                    .textSelection(.enabled)
                
                Button(role: .destructive) {
                    withAnimation {
                        message = ""
                    }
                } label: {
                    Image(systemName: "delete.backward")
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.red)
            .opacity(message.isEmpty ? 0 : 1)
            .listRowSeparator(.hidden)
            .transaction { $0.animation = nil }
        }
    }
}

#Preview {
    ErrorMessageView(message: .constant("No message"))
}
