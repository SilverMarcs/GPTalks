//
//  MaxTokensPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct MaxTokensPicker: View {
    @Binding var value: Int?
    let defaultValue: Int = 4096
    @State private var showPopover = false
    
    var body: some View {
        if let _ = value {
            Picker(selection: $value) {
                ForEach(options, id: \.self) { option in
                    Text(String(option)).tag(option)
                }
            } label: {
                labelView
            }
        } else {
            HStack {
                Text("Max Tokens")
                Spacer()
                Button("Set") {
                    self.value = defaultValue
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
            }
        }
    }
    
    @ViewBuilder
    var labelView: some View {
        HStack {
            Text("Max Tokens")
            
            Button {
                showPopover.toggle()
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .popover(isPresented: $showPopover) {
                #if os(macOS)
                HStack {
                    popoverContent
                }
                .padding(10)
                #else
                VStack(spacing: 15) {
                    popoverContent
                }
                .padding()
                .presentationCompactAdaptation(.popover)
                #endif
            }
        }
    }
    
    private var popoverContent: some View {
        Group {
            Button("Default") {
                self.value = defaultValue
            }
            
            Button(role: .destructive) {
                self.value = nil
            } label: {
                Text("Unset")
                    .foregroundStyle(.red)
            }
        }
    }
    
    let options = [512, 1024, 2048, 4096, 8192]
}

#Preview {
    MaxTokensPicker(value: .constant(4096))
}
