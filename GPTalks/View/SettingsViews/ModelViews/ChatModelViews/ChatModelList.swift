//
//  ChatModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ChatModelList: View {
    @Environment(\.modelContext) var modelContext
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Bindable var provider: Provider

    @State var showAdder = false
    @State var selections: Set<ChatModel> = []
    @State var isRefreshing = false
    @State private var showModelSelectionSheet = false
    @State private var refreshedModels: [ChatModel] = []
    
    var body: some View {
        Group {
            #if os(macOS)
            macOSContent
            #else
            iOSContent
            #endif
        }
        .sheet(isPresented: $showAdder) {
            ChatModelAdder(provider: provider)
        }
        .sheet(isPresented: $showModelSelectionSheet) {
            ModelSelectionSheet(
                refreshedModels: refreshedModels,
                onAddToChatModels: { selectedModels in
                    provider.chatModels.append(contentsOf: selectedModels)
                },
                onAddToImageModels: { selectedModels in
                    provider.imageModels.append(contentsOf: selectedModels.map { ImageModel(from: $0) })
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addButton
            }
        }
    }
    
    var searchPlacement: SearchFieldPlacement {
        #if os(macOS)
        return .toolbar
        #else
        return .navigationBarDrawer(displayMode: .always)
        #endif
    }
}

// MARK: - common foreach
extension ChatModelList {
    var collectiom: some View {
        ForEach($provider.chatModels) { $model in
            ChatModelRow(model: $model, provider: provider)
                .tag(model)
        }
        .onDelete(perform: deleteItems)
    }
    
    private func deleteItems(offsets: IndexSet) {
        provider.chatModels.remove(atOffsets: offsets)
    }
}

// MARK: - macOS Specific Views
#if os(macOS)
extension ChatModelList {
    var macOSContent: some View {
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
    
    var sectionHeader: some View {
        HStack(spacing: 0) {
            Text("Code")
                .frame(maxWidth: 300, alignment: .leading)
            Text("Name")
                .frame(maxWidth: 205, alignment: .leading)
            Text("Test")
                .frame(maxWidth: 35, alignment: .center)
        }
    }
}
#endif

// MARK: - iOS Specific Views
#if !os(macOS)
extension ModelListView {
    var iOSContent: some View {
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
extension ChatModelList {
    @ViewBuilder
    var addButton: some View {
        if isRefreshing {
            Button(action: {}) {
                Label("Refreshing", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
            }
            .symbolEffect(.rotate, isActive: isRefreshing)
            .disabled(true)
        } else {
            Menu {
                Button {
                    Task {
                        await refreshModels()
                    }
                } label: {
                    Label("Refresh Models", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                }
                
                Section {
                    Button(action: { showAdder = true }) {
                        Label("Add Custom Model", systemImage: "plus")
                    }
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    var editMenu: some View {
        Menu {
            Section {
                Button(action: { selections = Set(provider.chatModels) }) {
                    Label("Select All", systemImage: "checkmark.circle.fill")
                }
                
                Button(action: { selections.removeAll() }) {
                    Label("Deselect All", systemImage: "xmark.circle")
                }
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
    }
    
    func refreshModels() async {
        isRefreshing = true
        refreshedModels = await provider.refreshModels()
        isRefreshing = false
        showModelSelectionSheet = true
    }
}


#Preview {
    ChatModelList(provider: .openAIProvider)
}

