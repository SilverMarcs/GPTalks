//
//  ConversationShortcuts.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI

struct ConversationShortcuts: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Keyboard Shortcuts")
                .font(.title3)
                .bold()
            
            GroupBox {
                HStack {
                    Text("Send Prompt")
                    Spacer()
                    Text("⌘↩")
                }
                
                Divider()
                
                HStack {
                    Text("Paste Files from Clipboard")
                    Spacer()
                    Text("⌘B")
                }
                
                Divider()
                
                HStack {
                    Text("Stop Streaming")
                    Spacer()
                    Text("⌘D")
                }
            }
            
            GroupBox {
                HStack {
                    Text("Edit Last Message")
                    Spacer()
                    Text("⌘E")
                }
                
                Divider()
                
                HStack {
                    Text("Regenerate Last Message")
                    Spacer()
                    Text("⌘R")
                }
            }
            .padding(.vertical, 10)
            
            GroupBox {
                HStack {
                    Text("Reset Context")
                    Spacer()
                    Text("⌘K")
                }
                
                Divider()
                
                HStack {
                    Text("Delete Last Message")
                    Spacer()
                    Text("⌘⌫")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ConversationShortcuts()
}
