//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ModelRow: View {
    @Bindable var model: AIModel
    
    var body: some View {
        #if os(macOS)
        HStack(spacing: 0) {
            Toggle("Image", isOn: $model.supportsImage)
            .labelsHidden()
            .frame(width: 20, alignment: .leading)
            
            TextField("Code", text: $model.code)
            .frame(maxWidth: .infinity)
            .padding(.leading, 15)
            
            TextField("Name", text: $model.name)
            .frame(maxWidth: .infinity)
        }
        #else
        DisclosureGroup {
            Toggle("Image", isOn: $model.supportsImage)
            
            TextField("Code", text: $model.code)
            
            TextField("Name", text: $model.name)
        } label: {
            HStack {
                Text(model.name)
                Spacer()
                if model.supportsImage {
                    Image(systemName:  "photo")
                        .foregroundStyle(.secondary)
                        .imageScale(.small)
                }
            }
        }
        #endif
    }
}

#Preview {
    let model = AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
    
    ModelRow(model: model)
}
