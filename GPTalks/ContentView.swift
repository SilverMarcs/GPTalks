//
//  ContentView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DialogueData.date, ascending: false)],
        animation: .default)
    private var items: FetchedResults<DialogueData>
    
    @StateObject var configuration = AppConfiguration.shared
    @State var dialogueSessions: [DialogueSession] = []
    @State var selectedDialogueSession: DialogueSession?
    
#if os(iOS)
    @State var isShowSettingView = false
#endif

    var body: some View {
        NavigationSplitView {
            contentView()
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isShowSettingView = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
#endif
                    ToolbarItem {
                        Spacer()
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        Button {
                            addItem()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
        } detail: {
            if let selectedDialogueSession = selectedDialogueSession {
                MessageListView(session: selectedDialogueSession)
            } else {
                Text("Select a chat to see it here")
                    .font(.title)
            }
        }
        .onAppear() {
            dialogueSessions = items.compactMap {
                DialogueSession(rawData: $0)
            }
            #if os(macOS)
            if !dialogueSessions.isEmpty {
                selectedDialogueSession = dialogueSessions.first
            }
            #endif
        }
        .background(.background)
#if os(macOS)
        .frame(minWidth: 1100, minHeight: 770)
#else
        .sheet(isPresented: $isShowSettingView) {
            NavigationStack {
                AppSettingsView(configuration: configuration)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem {
                            Button {
                                isShowSettingView = false
                            } label: {
                                Text("Done")
                                    .bold()
                            }
                        }
                    }
            }
        }
#endif
    }
    
    
    @ViewBuilder
    func contentView() -> some View {
        if dialogueSessions.isEmpty {
            DialogueListPlaceholderView()
        } else {
            DialogueSessionListView(
                dialogueSessions: $dialogueSessions,
                selectedDialogueSession: $selectedDialogueSession
            ) {
                deleteItem($0)
            }
        }
    }


    private func addItem() {
        withAnimation {
            do {
                let session = DialogueSession()
                dialogueSessions.insert(session, at: 0)
                let newItem = DialogueData(context: viewContext)
                newItem.id = session.id
                newItem.date = session.date
                newItem.configuration =  try JSONEncoder().encode(session.configuration)
                try PersistenceController.shared.save()
                DispatchQueue.main.async {
                    selectedDialogueSession = dialogueSessions.first
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            dialogueSessions.remove(atOffsets: offsets)
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try PersistenceController.shared.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItem(_ session: DialogueSession) {
        withAnimation {
            dialogueSessions.removeAll {
                $0.id == session.id
            }
            if let item = session.rawData {
                viewContext.delete(item)
            }

            do {
                try PersistenceController.shared.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
