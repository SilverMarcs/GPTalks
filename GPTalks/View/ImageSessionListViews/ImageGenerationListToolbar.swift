//
//  ImageGenerationListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/07/2024.
//

import SwiftUI

struct ImageGenerationListToolbar: ToolbarContent {
    var session: ImageSession
    
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
