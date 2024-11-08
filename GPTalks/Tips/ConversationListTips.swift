//
//  ChatDetailTips.swift
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
        Text("Code Execution or Google Search Retrieval cannnot be used with other tools enabled")
    }
}
