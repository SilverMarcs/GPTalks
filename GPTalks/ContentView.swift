//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DialogueData.date, ascending: false)])
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
                                    deleteDialogue: deleteDialogue,
                                    addDialogue: addDialogue)
        } detail: {
            Group {
                if let selectedDialogueSession = selectedDialogueSession {
                    MessageListView(session: selectedDialogueSession)
                } else {
                    Text("Select a chat to see it here")
                        .font(.title)
                }
            }
            .background(.background)
        }
        .accentColor(selectedDialogueSession?.configuration.provider.accentColor ?? .accentColor)
        .onAppear {
            dialogueSessions = items.compactMap {
                DialogueSession(rawData: $0)
            }
            #if os(macOS)
            if let firstDialogueSession = dialogueSessions.first {
                selectedDialogueSession = firstDialogueSession
            }
            #endif
        }
    }


    private func addDialogue() {
        let session = DialogueSession()
        dialogueSessions.insert(session, at: 0)

        DispatchQueue.main.async {
            selectedDialogueSession = session
        }
        
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
    
    private func deleteDialogue(_ session: DialogueSession) {
        let sessionId = selectedDialogueSession?.id
        
        dialogueSessions.removeAll {
            $0.id == session.id
        }
        
        DispatchQueue.main.async {
            selectedDialogueSession = dialogueSessions.first(where: {
                $0.id == sessionId
            })
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
