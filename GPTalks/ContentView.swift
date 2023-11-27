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
        sortDescriptors: [NSSortDescriptor(keyPath: \DialogueData.date, ascending: false)])
    private var items: FetchedResults<DialogueData>
    
    @StateObject var configuration = AppConfiguration.shared
    @State var dialogueSessions: [DialogueSession] = []
    
#if os(iOS)
    @State var isShowSettingView = false
#endif

    var body: some View {
        NavigationView {
            DialogueSessionListView(dialogueSessions: $dialogueSessions,
                                    deleteDialogue: deleteDialogue,
                                    addDialogue: addDialogue)
        }
        .onAppear {
            DispatchQueue.main.async {
                dialogueSessions = items.compactMap {
                    DialogueSession(rawData: $0)
                }
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
    
    private func deleteDialogue(_ session: DialogueSession) {
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
