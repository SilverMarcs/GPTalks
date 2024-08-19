//
//  PasteTip.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/08/2024.
//

import SwiftUI
import TipKit

struct PasteTip: Tip {
    var title: Text {
        Text("Press Command + B to paste files from your clipboard to the chat")
    }
}

struct FocusTip: Tip {
    var title: Text {
        Text("Press Command + L to focus cursor on the textfield")
    }
}
    
