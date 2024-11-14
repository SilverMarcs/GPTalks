//
//  SecretInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/11/2024.
//

import SwiftUI

struct SecretInputView: View {
    var label: String
    @Binding var secret: String
    @State private var showKey: Bool = false

    var body: some View {
        HStack {
            if showKey {
                TextField(label, text: $secret)
            } else {
                SecureField(label, text: $secret)
            }
            
            Button {
                showKey.toggle()
            } label: {
                Image(systemName: !showKey ? "eye.slash" : "eye")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .truncationMode(.middle)
        .autocorrectionDisabled(true)
        #if !os(macOS)
        .textInputAutocapitalization(.never)
        #endif
    }
}
