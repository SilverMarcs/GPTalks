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
                Toggle("Supports Image", isOn: $supportsImage)
            }
            
            TextField("New Code", text: $newModelCode)
            TextField("New Name", text: $newModelName)
            
            Section {
                Button(action: addModel) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage)
        
        provider.models.append(model)
        
        dismiss()

//        supportsImage = false
//        newModelCode = ""
//        newModelName = ""
    }
}

#Preview {
    ModelAdder(provider: Provider.factory(type: .openai))
}
