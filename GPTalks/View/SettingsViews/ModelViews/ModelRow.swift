//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ModelRow: View {
    @Bindable var model: Model
    
    var body: some View {
        HStack {
            Group {
                TextField("Code", text: $model.code)
                
                TextField("Name", text: $model.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                model.removeSelf()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let model = Model(code: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
    
    ModelRow(model: model)
}
