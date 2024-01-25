//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import Combine
import CoreData
import SwiftUI

@Observable class DialogueViewModel {
    private let viewContext: NSManagedObjectContext

    var allDialogues: [DialogueSession] = [] {
        didSet {
            if isArchivedSelected {
                dialogues = allDialogues.filter { $0.isArchive }
            } else {
                dialogues = allDialogues.filter { !$0.isArchive }
            }
        }
    }

    var dialogues: [DialogueSession] = []

    var isArchivedSelected: Bool = false

//    var searchText: String = ""
//    var filteredDialogues: [DialogueSession] = []
    var selectedDialogue: DialogueSession?

    init(context: NSManagedObjectContext) {
        viewContext = context
        fetchDialogueData()

//        Publishers.CombineLatest(dialogues, $searchText)
//            .map { dialogues, searchText in
//                searchText.isEmpty ? dialogues : dialogues.filter { dialogue in
//                    dialogue.title.localizedCaseInsensitiveContains(searchText)
//                }
//            }
//            .assign(to: &$filteredDialogues)
    }

    func fetchDialogueData(firstTime: Bool = true) {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }

            dialogues = allDialogues.filter { !$0.isArchive }

            #if os(macOS)
                if firstTime {
                    selectedDialogue = dialogues.first
                }
            #endif
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }

    func toggleArchivedStatus() {
        isArchivedSelected.toggle()
        
        withAnimation {
            if isArchivedSelected {
//                if selectedDialogue?.isArchive == false {
//                    selectedDialogue = nil
//                }
                
                dialogues = allDialogues.filter { $0.isArchive }
            } else {
//                if selectedDialogue?.isArchive == true {
//                    selectedDialogue = nil
//                }
                
                dialogues = allDialogues.filter { !$0.isArchive }
            }
        }
    }

    func toggleArchive(session: DialogueSession) {
        session.toggleArchive()

//        if let selectedDialogue = selectedDialogue, selectedDialogue.id == session.id {
//            self.selectedDialogue = nil
//        }

        withAnimation {
            dialogues.removeAll {
                $0.id == session.id
            }
        }
    }

    func addDialogue() {
        isArchivedSelected = false
        
        let session = DialogueSession()
        withAnimation {
            allDialogues.insert(session, at: 0)
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
            self.allDialogues.removeAll {
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
