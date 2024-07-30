//
//  ModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

struct ModelListView: View {
    @Environment(\.modelContext) var modelContext
    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Bindable var provider: Provider
    
    @State private var showAdder = false
    @State private var selections: Set<AIModel> = []
    @State private var searchText = ""
    
    let modelType: ModelType
    
    var models: [AIModel] {
        switch modelType {
        case .chat: return provider.chatModels
        case .image: return provider.imageModels
        }
    }
    
    var body: some View {
        Group {
            #if os(macOS)
            macOSContent
            #else
            iOSContent
            #endif
        }
        .sheet(isPresented: $showAdder) {
            ModelAdder(provider: provider, modelType: modelType)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addButton
            }
        }
        .searchable(text: $searchText, placement: searchPlacement)
    }
    
    private var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .toolbar
        #else
        return .navigationBarDrawer(displayMode: .always)
        #endif
    }
    
    private var filteredModels: [AIModel] {
        let filtered = searchText.isEmpty ? models : models.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.code.localizedCaseInsensitiveContains(searchText) }
        return filtered.sorted { $0.order < $1.order }
    }
}

// Mardk: - common foreach
extension ModelListView {
    private var collectiom: some View {
        ForEach(filteredModels, id: \.self) { model in
            ModelRow(model: model) {
                reorderModels()
            }
            #if os(macOS)
                .contextMenu { contextMenuItems(for: model) }
            #endif
        }
        .onDelete(perform: deleteItems)
        .onMove(perform: moveItems)
        .moveDisabled(!searchText.isEmpty)
    }
}

// MARK: - macOS Specific Views
#if os(macOS)
extension ModelListView {
    private var macOSContent: some View {
        Form {
            List(selection: $selections) {
                Section(header: sectionHeader) {
                    collectiom
                }
            }
            .labelsHidden()
            .alternatingRowBackgrounds()
        }
        .formStyle(.grouped)
    }
    
    private var sectionHeader: some View {
        HStack(spacing: 5) {
            Text("Show").frame(maxWidth: 30, alignment: .center)
            Text("Code").frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
            Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, -3)
        }
    }
}
#endif

// MARK: - iOS Specific Views
#if !os(macOS)
extension ModelListView {
    private var iOSContent: some View {
        List(selection: $selections) {
            collectiom
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    EditButton()
                    Spacer()
                    if editMode?.wrappedValue == .active {
                        editMenu
                    }
                }
            }
        }
    }
}
#endif

// MARK: - Shared Components
extension ModelListView {
    private var addButton: some View {
        Menu {
            Button(action: refreshModels) {
                Label("Refresh Models", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
            }
            
            Button(action: { showAdder = true }) {
                Label("Add Custom Model", systemImage: "plus")
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
    
    private var editMenu: some View {
        Menu {
            Section {
                commonMenuItems(for: Array(selections))
            }
            
            Section {
                Button(action: { selections = Set(filteredModels) }) {
                    Label("Select All", systemImage: "checkmark.circle.fill")
                }
                
                Button(action: { selections.removeAll() }) {
                    Label("Deselect All", systemImage: "xmark.circle")
                }
            }
            
            Section {
                Button(role: .destructive, action: deleteSelectedModels) {
                    Label("Delete Selected", systemImage: "trash")
                }
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
    }
    
    private func contextMenuItems(for model: AIModel) -> some View {
        commonMenuItems(for: selections.isEmpty ? [model] : Array(selections))
    }
    
    private func commonMenuItems(for models: [AIModel]) -> some View {
        Group {
            Button(action: { toggleEnabled(for: models) }) {
                Label("Toggle Enabled", systemImage: "power")
            }
            
            Button(action: { toggleModelType(for: models) }) {
                Label("Toggle Chat/Image", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }
}

extension ModelListView {
    private func testModel(model: AIModel) {
        print("Not Implemented Yet")
    }
    
    private func refreshModels() {
        Task { @MainActor in
            await provider.refreshModels()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let sortedModels = models.sorted(by: { $0.order < $1.order })
        let sortedIndices = offsets.map { sortedModels[$0].id }
        
        switch modelType {
        case .chat:
            provider.chatModels.removeAll { sortedIndices.contains($0.id) }
        case .image:
            provider.imageModels.removeAll { sortedIndices.contains($0.id) }
        }
        
        reorderModels()
    }

    private func deleteSelectedModels() {
        switch modelType {
        case .chat:
            provider.chatModels.removeAll { selections.contains($0) }
        case .image:
            provider.imageModels.removeAll { selections.contains($0) }
        }
        
        selections.removeAll()
        reorderModels()
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var sortedModels = models.sorted(by: { $0.order < $1.order })
        sortedModels.move(fromOffsets: source, toOffset: destination)
        
        reorderModels(sortedModels)
    }

    private func reorderModels(_ customOrder: [AIModel]? = nil) {
        let modelsToReorder = customOrder ?? models
        let enabledModels = modelsToReorder.filter { $0.isEnabled }
        let disabledModels = modelsToReorder.filter { !$0.isEnabled }
        
        let reorderedModels = enabledModels + disabledModels
        
        for (index, model) in reorderedModels.enumerated() {
            withAnimation {
                model.order = index
            }
        }
        
        switch modelType {
        case .chat:
            provider.chatModels = reorderedModels.compactMap { $0 }
        case .image:
            provider.imageModels = reorderedModels.compactMap { $0 }
        }
    }
    
    private func toggleModelType(for models: [AIModel]) {
        for model in models {
            if model.modelType == .chat {
                model.modelType = .image
            } else {
                model.modelType = .chat
            }
        }
    }
    
    private func toggleEnabled(for models: [AIModel]) {
        for model in models {
            model.isEnabled.toggle()
        }
    }
}

#Preview {
    ModelListView(provider: Provider.factory(type: .openai), modelType: .chat)
}
