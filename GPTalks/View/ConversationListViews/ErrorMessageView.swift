//
//  ErrorMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ErrorMessageView: View {
    var session: Session
    
    var body: some View {
        if !session.errorMessage.isEmpty {
            HStack {
                Text(session.errorMessage)
                
                Button(role: .destructive) {
                    withAnimation {
                        session.errorMessage = ""
                    }
                } label: {
                    Image(systemName: "delete.backward")
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.red)
        }
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    ErrorMessageView(session: session)
}
