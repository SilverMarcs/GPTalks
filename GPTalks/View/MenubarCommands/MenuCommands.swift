//
//  MenuCommands.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct MenuCommands: Commands {
    var sessionVM: SessionVM

    var body: some Commands {
        switch sessionVM.state {
        case .chats:
            ChatCommands(sessionVM: sessionVM)
        case .images:
            ImageCommands(sessionVM: sessionVM)
        }
    }
}
