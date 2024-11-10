//
//  Tips.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/11/2024.
//

import TipKit

struct PlusButtonTip: Tip {
    var title: Text {
        #if os(macOS)
        Text("Long Tap the plus button to see more input options and ⌘ + L to focus on input box")
        #else
        Text("Long Tap the plus button to see more input options")
        #endif
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}
struct SwipeActionTip: Tip {
    var title: Text {
        Text("Swipe left or right on list row for actions")
    }
    
    var image: Image {
        Image(systemName: "hand.draw.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct ChatCardTip: Tip {
    var title: Text {
        Text("Click on the Chats card to cycle beterrn Starred or Archived chats")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct GenerateTitleTip: Tip {
    var title: Text {
        Text("Generate Title")
    }
}

struct GoogleCodeExecutionTip: Tip {
    var title: Text {
        Text("Code Execution or Google Search Retrieval cannnot be used with other tools enabled")
    }
}

struct ProviderRefreshTip: Tip {
    var title: Text {
        Text("Go into Models Section to refresh the provider's model list")
    }
}

struct NewChatTip: Tip {
    var title: Text {
        Text("Long Tap to see list of all providers")
    }
    
    var message: Text {
        Text("Long Tap the plus button to see list of all providers")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
    
//    var image: Image {
//        Image(systemName: "plus")
//    }
    
//    var actions: [Action] {
//        Action(id: "provider-list", title: "Provider Settings")
//        Action(id: "faq", title: "View our FAQ")
//    }
    
//    var options: [Option] {
//        MaxDisplayCount(2)
//    }
}

struct OpenSettingsTip: Tip {
    var title: Text {
        Text("Configure more in settings")
    }
    
    var actions: [Action] {
        Action(id: "launch-settings", title: "Settings (⌘ + ,)")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct QuickPanelTip: Tip {
    var title: Text {
        Text("Launch Floating Chat Window")
    }
    
    var actions: [Action] {
        Action(id: "launch-quick-panel", title: "⌥ + Space")
    }
}

struct ChatInspectorTip: Tip {
    var title: Text {
        Text("Tap Top left icon of the page to configure chat options like plugins, temperature, max tokens etc")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct ChatInspectorToolsTip: Tip {
    var title: Text {
        Text("Tap Advanced for configuring lugins")
    }
    
    var options: [Option] {
        MaxDisplayCount(2)
    }
}
    
