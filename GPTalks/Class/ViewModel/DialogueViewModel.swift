//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import Combine
import CoreData
import SwiftUI

class DialogueViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var dialogues: [DialogueSession] = []
    @Published var archivedDialogues: [DialogueSession] = []

    @Published var isArchivedSelected: Bool = false
    
    @Published var searchText: String = ""
    @Published var filteredDialogues: [DialogueSession] = []
    @Published var selectedDialogue: DialogueSession?

    init(context: NSManagedObjectContext) {
        viewContext = context
        fetchDialogueData()

        Publishers.CombineLatest($dialogues, $searchText)
            .map { dialogues, searchText in
                searchText.isEmpty ? dialogues : dialogues.filter { dialogue in
                    dialogue.title.localizedCaseInsensitiveContains(searchText)
                }
            }
            .assign(to: &$filteredDialogues)
    }

    func fetchDialogueData(firstTime: Bool = true) {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            
            let tempDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }
            archivedDialogues = tempDialogues.filter { $0.isArchive }
            dialogues = tempDialogues.filter { !$0.isArchive }
            
            #if os(macOS)
            if firstTime {
                selectedDialogue = dialogues.first
            }
            #endif
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }
    
    func toggleArchive(session: DialogueSession) {
        if session.isArchive {
            unarchiveDialogue(session)
        } else {
            archiveDialogue(session)
        }
    }

    func archiveDialogue(_ session: DialogueSession) {
        session.toggleArchive()
        
        if let selectedDialogue = selectedDialogue, selectedDialogue.id == session.id {
            self.selectedDialogue = nil
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.dialogues.removeAll {
                    $0.id == session.id
                }
            }
            
            self.fetchDialogueData(firstTime: false)
        }
    }
    
    func unarchiveDialogue(_ session: DialogueSession) {
        session.toggleArchive()
        
        if let selectedDialogue = selectedDialogue, selectedDialogue.id == session.id {
            self.selectedDialogue = nil
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.archivedDialogues.removeAll {
                    $0.id == session.id
                }
            }

            self.fetchDialogueData(firstTime: false)
        }
    }
    
    func addDialogue() {
        let session = DialogueSession()
        withAnimation {
            dialogues.insert(session, at: 0)
        }
            
        let newItem = DialogueData(context: viewContext)
        newItem.id = session.id
        newItem.date = session.date

        do {
            newItem.configuration = try JSONEncoder().encode(session.configuration)
        } catch {
            print(error.localizedDescription)
        }

        save()
    }
    
    func deleteDialogue(_ session: DialogueSession) {
        if selectedDialogue == session {
            selectedDialogue = nil
        }
        
        withAnimation {
            self.dialogues.removeAll {
                $0.id == session.id
            }
        }
        
        withAnimation {
            self.archivedDialogues.removeAll {
                $0.id == session.id
            }
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
