//
//  ModelPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var model: AIModel
    var models: [AIModel]
    var label: String = "Model"
    
    var body: some View {
        Picker(label, selection: $model) {
            ForEach(models.filter({ $0.isEnabled })) { model in
                Text(model.name)
                    .tag(model)
            }
        }
    }
}
