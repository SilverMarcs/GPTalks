//
//  ModelAdder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/07/2024.
//

import SwiftUI

struct ModelAdder: View {
    @Environment(\.dismiss) var dismiss
    var provider: Provider
    
    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    @State var supportsImage: Bool = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Image", isOn: $supportsImage)
            }
            
            TextField("Code", text: $newModelCode)
            TextField("Name", text: $newModelName)
            
            Section {
                Button(action: addModel) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage)
        
        provider.models.append(model)
        
        dismiss()
    }
}

#Preview {
    ModelAdder(provider: Provider.factory(type: .openai))
}
