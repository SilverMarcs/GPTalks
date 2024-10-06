//
//  ChatModelPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ChatModelPicker: View {
    @Binding var model: ChatModel
    var models: [ChatModel]
    var label: String = "Model"
    
    var body: some View {
        Picker(label, selection: $model) {
            ForEach(models) { model in
                Text(model.name)
                    .tag(model)
            }
        }
    }
}
