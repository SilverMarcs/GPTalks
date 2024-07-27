//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ModelRow<T: AIModel>: View {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Bindable var model: T
    @Binding var selections: Set<T>
    
    var body: some View {
        Group {
#if os(macOS)
            HStack(spacing: 0) {
                Toggle("Enabled", isOn: $model.isEnabled)
                    .frame(width: 30, alignment: .center)

                TextField("Code", text: $model.code)
                    .padding(.leading, 17)
                
                TextField("Name", text: $model.name)
                
            }
#else
            Group {
                if editMode?.wrappedValue == .active {
                    VStack(alignment: .leading) {
                        Text(model.name)
                        Text(model.code)
                    }
                } else {
                    DisclosureGroup {
                        TextField("Code", text: $model.code)
                        
                        TextField("Name", text: $model.name)
                        
                    } label: {
                        Text(model.name)
                    }
                }
            }
            .opacity(model.isEnabled ? 1 : 0.5)
#endif
        }
        .swipeActions(edge: .leading) {
            #if !os(macOS)
            Button {
                model.isEnabled.toggle()
            } label: {
                Image(systemName: model.isEnabled ? "xmark" : "checkmark")
            }
            .tint(model.isEnabled ? .gray.opacity(0.7) : .accentColor)
            #endif
            
            Button {
                model.modelType = model.modelType == .image ? .chat : .image
            } label: {
                Image(systemName: model.modelType == .chat ? "photo" : "bubble.left")
            }
            .tint(model.modelType == .chat ? .pink : .green)
        }
    }
}

#Preview {
    let model = AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
    
    ModelRow(model: model, selections: .constant([]))
}
