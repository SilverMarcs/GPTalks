//
//  ModelPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import SwiftUI

struct ModelPicker<T: ModelType>: View {
    @Binding var model: T
    var models: [T]
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
