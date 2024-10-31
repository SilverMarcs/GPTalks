//
//  ConversationListTips.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/08/2024.
//

import TipKit

struct GenerateTitleTip: Tip {
    var title: Text {
        Text("Generate Title")
    }
}

struct GoogleCodeExecutionTip: Tip {
    var title: Text {
        Text("Code Execution cannnot be used with other tools enabled")
    }
}
