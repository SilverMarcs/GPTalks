
//
//  ImageModelPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ImageModelPicker: View {
    @Binding var model: ImageModel
    var models: [ImageModel]
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
