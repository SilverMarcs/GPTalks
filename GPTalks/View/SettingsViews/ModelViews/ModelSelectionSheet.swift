//
//  ModelSelectionSheet.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var refreshedModels: [GenericModel] = []
    @State private var isLoading = true
    var provider: Provider
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading models...")
                    .task {
                        await loadModels()
                    }
            } else {
                Form {
                    List($refreshedModels) { $selectableModel in
                        HStack {
                            Toggle(isOn: $selectableModel.isSelected) {
                                Text("\(selectableModel.code)")
                                Text("\(selectableModel.name)")
                            }
                            
                            Spacer()
                            
                            Picker("Model Type", selection: $selectableModel.selectedModelType) {
                                ForEach(ModelTypeOption.allCases, id: \.self) { option in
                                    Image(systemName: option.icon)
                                        .tag(option)
                                }
                            }
                            .onChange(of: selectableModel.selectedModelType) {
                                selectableModel.isSelected = true
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                            .fixedSize()
                        }
                    }
                }
                .navigationTitle("Select models to add")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Add") {
                        addSelectedModels()
                    }
                }
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .frame(width: 400, height: 450)
        #endif
    }
    
    private func loadModels() async {
        refreshedModels = await provider.refreshModels()
        isLoading = false
    }
    
    private func addSelectedModels() {
        let selectedModels = refreshedModels.filter { $0.isSelected }
        
        for selectableModel in selectedModels {
            switch selectableModel.selectedModelType {
            case .chat:
                let chatModel = ChatModel(code: selectableModel.code, name: selectableModel.name)
                provider.chatModels.append(chatModel)
            case .image:
                let imageModel = ImageModel(code: selectableModel.code, name: selectableModel.name)
                provider.imageModels.append(imageModel)
            case .stt:
                let sttModel = STTModel(code: selectableModel.code, name: selectableModel.name)
                provider.sttModels.append(sttModel )
            }
        }
        
        dismiss()
    }
}
