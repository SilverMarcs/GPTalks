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
            DialogueSessionListView(dialogueSessions: $dialogueSessions,
                                    selectedDialogueSession: $selectedDialogueSession,
                                    deleteDialogue: deleteDialogues,
                                    addDialogue: addDialogue)
        } detail: {
            if let selectedDialogueSession = selectedDialogueSession {
                MessageListView(session: selectedDialogueSession)
            } else {
                Text("Select a chat to see it here")
                    .font(.title)
            }
        }
        .onAppear {
            dialogueSessions = items.compactMap {
                DialogueSession(rawData: $0)
            }
        }
    }


    private func addDialogue() {
        let session = DialogueSession()
        dialogueSessions.insert(session, at: 0)
        let newItem = DialogueData(context: viewContext)
        newItem.id = session.id
        newItem.date = session.date
        
        do {
            newItem.configuration =  try JSONEncoder().encode(session.configuration)
        } catch {
            print(error.localizedDescription)
        }

        save()
    }

    private func deleteDialogues(offsets: IndexSet) {
        withAnimation {
            dialogueSessions.remove(atOffsets: offsets)
            offsets.map { items[$0] }.forEach(viewContext.delete)
        }
        save()
    }
    
    private func deleteDialogues(_ session: DialogueSession) {
            dialogueSessions.removeAll {
                $0.id == session.id
            }
            if let item = session.rawData {
                viewContext.delete(item)
            }
        save()
    }
    
    private func save() {
        do {
            try PersistenceController.shared.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
