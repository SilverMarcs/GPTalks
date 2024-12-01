//
//  AssistantLabel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 01/12/2024.
//

import SwiftUI

struct AssistantLabel: View {
    var message: Message
    
    var body: some View {
        #if os(macOS)
        Label {
            text
        } icon: {
            image
        }
        #else
        HStack {
            image
            text
        }
        #endif
    }
    
    var image: some View {
        Image(message.provider?.type.imageName ?? "brain.SFSymbol")
            .imageScale(.large)
            .foregroundStyle(Color(hex: message.provider?.color ?? "#00947A").gradient)
    }
    
    var text: some View {
        Text(message.model?.name ?? "Assistant")
            .font(.subheadline)
            .bold()
            .foregroundStyle(.secondary)
    }
}
