//
//  PasteTip.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/08/2024.
//

import SwiftUI
import TipKit

struct PlusButtonTip: Tip {
    var title: Text {
        Text("Long Press the plus button to see more options")
    }
}

struct FocusTip: Tip {
    var title: Text {
        Text("Press Command + L to focus cursor on the textfield")
    }
}
    
