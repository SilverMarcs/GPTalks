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
    @State var isRefreshing = false
    @State private var showModelSelectionSheet = false
    @State private var refreshedModels: [ChatModel] = []
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif
        
    var body: some View {
        Group {
#if os(macOS)
            Form {
                table
            }
            .formStyle(.grouped)
            .labelsHidden()
#else
            table
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

    var table: some View {
        Table($provider.chatModels) {
            TableColumn("Code") { $model in
                HStack {
                    TextField("Code", text: $model.code)
                    
                    if isCompact {
                        Spacer()
                        Button {
                            provider.chatModels.removeAll(where: { $0.id == model.id })
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            #if os(macOS)
            .width(250)
            #endif
            .alignment(.leading)
            
            TableColumn("Name") { $model in
                TextField("Name", text: $model.name)
            }
            .width(200)
            
            TableColumn("Action") { model in
                Button {
                    provider.chatModels.removeAll(where: { $0.id == model.id })
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .width()
            .alignment(.trailing)
        }
    }
    
    func refreshModels() async {
        isRefreshing = true
        refreshedModels = await provider.refreshModels()
        isRefreshing = false
        showModelSelectionSheet = true
    }
}

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
}


#Preview {
    ChatModelList(provider: .openAIProvider)
}

