//
//  SessionListTips.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftUI
import TipKit

struct NewSessionTip: Tip {
    var title: Text {
        Text("Long Tap to see list of all providers")
    }
    
//    var message: Text {
//        Text("Long Tap the button to see list of all providers")
//    }
    
//    var image: Image {
//        Image(systemName: "plus")
//    }
    
//    var actions: [Action] {
//        [
//            Tip.Action(
//                id: "provider-list",
//                title: "Provider Settings") {
//                    // do sth
//                }
//        ]
//    }
}

struct FavouriteTip: Tip {
    var title: Text {
        Text("Swipe left or right on list row to favourite or delete a session")
    }
}

struct DragSessionTip: Tip {
    var title: Text {
        Text("Drag and drop sessions to reorder them")
    }
}
