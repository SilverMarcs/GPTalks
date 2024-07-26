//
//  ModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

struct ChatModelListView: View {
    @Bindable var provider: Provider
    
    var body: some View {
        ModelListView(provider: provider, models: $provider.chatModels, modelType: .chat)
    }
}

struct ImageModelListView: View {
    @Bindable var provider: Provider
    
    var body: some View {
        ModelListView(provider: provider, models: $provider.imageModels, modelType: .image)
    }
}

struct ModelListView<T: AIModel>: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider
    @Binding var models: [T]
    
    @State var showAdder: Bool = false
    @State private var selections: Set<T> = []
    @State var searchText: String = ""
    
    var modelType: ModelType
    
    var body: some View {
        content
            .sheet(isPresented: $showAdder) {
                ModelAdder(provider: provider, modelType: modelType)
            }
            .toolbar {
                toolbarItem
            }
            #if os(macOS)
            .searchable(text: $searchText, placement: .toolbar)
            #else
            .searchable(text: $searchText, placement: .navigationBarDrawer)
            #endif
    }

    #if os(macOS)
    var content: some View {
        Form {
            List(selection: $selections) {
                Section(header:
                    HStack(spacing: 5) {
                        Text("Show").frame(maxWidth: 30, alignment: .center)
                        Text("Code").frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    }
                ) {
                    ForEach(filteredModels, id: \.self) { model in
                        ModelRow(model: model, selections: $selections)
                        .contextMenu {
                            Button(action: {
                                toggleModelType(for: selections.isEmpty ? [model] : Array(selections))
                            }) {
                                Label("Toggle Chat/Image", systemImage: "arrow.triangle.2.circlepath")
                            }
                            
                            Button(action: {
                                toggleEnabled(for: selections.isEmpty ? [model] : Array(selections))
                            }) {
                                Label("Toggle Enabled", systemImage: "power")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
            }
            .alternatingRowBackgrounds()
            .labelsHidden()
        }
        .formStyle(.grouped)
    }
    #else
    @Environment(\.editMode) var editMode
    var content: some View {
        List(selection: $selections) {
            ForEach(filteredModels, id: \.self) { model in
                ModelRow(model: model, selections: $selections)
            }
            .onDelete(perform: deleteItems)
            .onMove(perform: moveItems)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    EditButton()

                    Spacer()
                    
                    if editMode?.wrappedValue == .active {
                        Menu {
                            Section {
                                Button {
                                    toggleModelType(for: Array(selections))
                                } label: {
                                    Label("Toggle Chat/Image", systemImage: "photo")
                                }
                                
                                Button {
                                    toggleEnabled(for: Array(selections))
                                } label: {
                                    Label("Toggle Enabled", systemImage: "power")
                                }
                            }
                            
                            
                            Section {
                                Button {
                                    selections = Set(filteredModels)
                                } label: {
                                    Label("Select All", systemImage: "checkmark.circle")
                                        .labelStyle(.iconOnly)
                                }
                                
                                Button {
                                    selections = []
                                } label: {
                                    Label("Deselect All", systemImage: "xmark.circle")
                                        .labelStyle(.iconOnly)
                                }
                            }
                            
                            Section {
                                Button(role: .destructive) {
                                    for model in selections {
                                        provider.models.removeAll { $0.id == model.id }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.white, .red)
                                }
                            }
                        } label: {
                            Label("Actions", systemImage: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
    #endif
    
    var filteredModels: [T] {
        if searchText.isEmpty {
            return models.sorted(by: { $0.order < $1.order })
        } else {
            return models.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                                  .sorted(by: { $0.order < $1.order })
        }
    }

    
    var toolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Section {
                    Button {
                        Task { @MainActor in
                            await provider.refreshModels()
                        }
                    } label: {
                        Label("Refresh Models", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    }
                }
                
                Button {
                    showAdder = true
                } label: {
                    Label("Add Custom Model", systemImage: "plus")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .fixedSize()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let sortedModels = models.sorted(by: { $0.order < $1.order })
        let sortedIndices = offsets.map { sortedModels[$0].id }
        models.removeAll { sortedIndices.contains($0.id) }
        
        // Update the order of remaining items
        for (index, model) in models.enumerated() {
            model.order = index
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var sortedModels = models.sorted(by: { $0.order < $1.order })
        sortedModels.move(fromOffsets: source, toOffset: destination)
        
        for (index, model) in sortedModels.enumerated() {
            withAnimation {
                model.order = index
            }
        }
        
        models = sortedModels
    }
    
    private func toggleModelType(for models: [T]) {
        for model in models {
            if model.modelType == .chat {
                model.modelType = .image
            } else {
                model.modelType = .chat
            }
        }
    }
    
    private func toggleEnabled(for models: [T]) {
        for model in models {
            model.isEnabled.toggle()
        }
    }
}
