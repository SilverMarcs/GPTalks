//
//  ConversationToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    @Bindable var session: Session
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {
                
            } label: {
                Image(systemName: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
    }
}
