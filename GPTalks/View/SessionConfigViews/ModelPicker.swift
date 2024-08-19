//
//  ModelPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ModelPicker: View {
    @Binding var model: AIModel
    var models: [AIModel]
    var label: String = "Model"
    
    var body: some View {
        Picker(label, selection: $model) {
            ForEach(filteredModels) { model in
                Text(model.name)
                    .tag(model)
            }
        }
    }
    
    private var filteredModels: [AIModel] {
        models
            .filter { $0.isEnabled }
            .sorted { $0.name < $1.name }
    }
}
