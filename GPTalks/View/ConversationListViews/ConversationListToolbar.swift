//
//  ConversationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ConversationListToolbar: ToolbarContent {
    var session: Session
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {

            } label: {
                Image(systemName: "slider.vertical.3")
            }
            .menuIndicator(.hidden)
        }
        
        ToolbarItem {
            Color.clear
            .sessionExporter(isExporting: $isExportingJSON, sessions: [session])
            
            Color.clear
            .markdownSessionExporter(isExporting: $isExportingMarkdown, session: session)
        }
    
        ToolbarItem {
            Menu {
                Button {
                    isExportingJSON = true
                } label: {
                    Label("JSON", systemImage: "ellipsis.curlybraces")
                }
                
                Button {
                    isExportingMarkdown = true
                } label: {
                    Label("Markdown", systemImage: "richtext.page")
                }

            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
                    .labelStyle(.titleOnly)
            }
        }
    }
}
