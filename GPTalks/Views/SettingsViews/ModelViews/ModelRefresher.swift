//
//  ModelRefresher.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelRefresher: View {
    @Environment(\.dismiss) var dismiss

    @State private var refreshedModels: [GenericModel] = []
    @State private var isLoading = true
    @State private var searchText: String = ""

    var provider: Provider

    var body: some View {
        NavigationStack {
            Form {
                if isLoading {
                    ProgressView("Loading models...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task {
                            await loadModels()
                        }
                } else {
                    if filteredModels.isEmpty {
                        ContentUnavailableView.search
                    } else {
                        List {
                            ForEach(filteredModels) { selectableModel in
                                HStack {
                                    Toggle(isOn: $refreshedModels[refreshedModels.firstIndex(where: { $0.id == selectableModel.id })!].isSelected) {
                                        VStack(alignment: .leading) {
                                            Text(selectableModel.code)
                                            Text(selectableModel.name)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Picker("Model Type", selection: $refreshedModels[refreshedModels.firstIndex(where: { $0.id == selectableModel.id })!].selectedModelType) {
                                        ForEach(ModelType.allCases, id: \.self) { option in
                                            Image(systemName: option.icon)
                                                .tag(option)
                                        }
                                    }
                                    .onChange(of: selectableModel.selectedModelType) {
                                        refreshedModels[refreshedModels.firstIndex(where: { $0.id == selectableModel.id })!].isSelected = true
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.segmented)
                                    .fixedSize()
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .searchable(text: $searchText, prompt: "Search models")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSelectedModels()
                    }
                    .disabled(refreshedModels.filter { $0.isSelected }.isEmpty)
                }
            }
            #if os(macOS)
            .padding(.top)
            .frame(width: 400, height: 450)
            #else
            .navigationTitle("Add Models")
            #endif
        }
    }

    private var filteredModels: [GenericModel] {
        if searchText.isEmpty {
            return refreshedModels
        } else {
            return refreshedModels.filter { model in
                model.name.localizedCaseInsensitiveContains(searchText) ||
                model.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func loadModels() async {
        refreshedModels = await provider.refreshModels()
        isLoading = false
    }

    private func addSelectedModels() {
        let selectedModels = refreshedModels.filter { $0.isSelected }

        for model in selectedModels {
            provider.models.append(.init(code: model.code, name: model.name, type: model.selectedModelType))
        }

        dismiss()
    }
}
