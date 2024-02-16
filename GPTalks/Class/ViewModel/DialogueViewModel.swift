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
                archivedDialogues = allDialogues.filter { $0.isArchive }
            } else {
                activeDialogues = allDialogues.filter { !$0.isArchive }
            }
        }
    }

    
//    var allDialogues: [DialogueSession] = []

    var dialogues: [DialogueSession] = []
    
    var activeDialogues: [DialogueSession] = [] 
//    {
//        didSet {
//            allDialogues.filter { !$0.isArchive }
//        }
//    }
    
    var archivedDialogues: [DialogueSession] = [] 
//    {
//        didSet {
//            allDialogues.filter { $0.isArchive }
//        }
//    }

//    var isArchivedSelected: Bool = false {
//        didSet {
//            withAnimation {
//                if isArchivedSelected {
//                    dialogues = archivedDialogues
//                } else {
//                    dialogues = activeDialogues
//                }
//            }
//        }
//    }
    
    var isArchivedSelected: Bool = false

    var searchText: String = "" {
        didSet {
//            if searchText.isEmpty {
//                 if isArchivedSelected {
////                     dialogues = allDialogues.filter { $0.isArchive }
//                     archivedDialogues = allDialogues
//
//                 } else {
////                     dialogues = allDialogues.filter { !$0.isArchive }
//                     activeDialogues = allDialogues
//                 }
//             } else {
            if !searchText.isEmpty {
                 if isArchivedSelected {
                     archivedDialogues = allDialogues.filter { dialogue in
                         dialogue.title.localizedCaseInsensitiveContains(searchText)
                     }
                 } else {
                     activeDialogues = allDialogues.filter { dialogue in
                         dialogue.title.localizedCaseInsensitiveContains(searchText)
                     }
                 }
            } else {
                if isArchivedSelected {
                    archivedDialogues = allDialogues.filter { $0.isArchive }
                } else {
                    activeDialogues = allDialogues.filter { !$0.isArchive }
                }
            }
        }
    }
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
    
    var shouldShowPlaceholder: Bool {
        if isArchivedSelected {
            return archivedDialogues.isEmpty
        } else {
            return activeDialogues.isEmpty
        }
    }
    
    var currentDialogues: [DialogueSession] {
        if isArchivedSelected {
            return archivedDialogues
        } else {
            return activeDialogues
        }
    }

    func fetchDialogueData(firstTime: Bool = true) {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }

            dialogues = allDialogues.filter { !$0.isArchive } // why cant i get rid of this?
            
            activeDialogues = allDialogues.filter { !$0.isArchive }
            archivedDialogues = allDialogues.filter { $0.isArchive }

            #if os(macOS)
                if firstTime {
                    selectedDialogue = activeDialogues.first
                }
            #endif
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }

    func toggleArchivedStatus() {
        isArchivedSelected.toggle()
        
//        withAnimation {
//            if isArchivedSelected {
//                dialogues = allDialogues.filter { $0.isArchive }
//            } else {
//                dialogues = allDialogues.filter { !$0.isArchive }
//            }
//        }
    }

    func toggleArchive(session: DialogueSession) {
        session.toggleArchive()
        
        if isArchivedSelected {
            withAnimation {
                archivedDialogues.removeAll {
                    $0.id == session.id
                }
                activeDialogues.append(session)
                activeDialogues.sort {
                    $0.date > $1.date
                }
            }
            } else {
                withAnimation {
                    activeDialogues.removeAll {
                        $0.id == session.id
                    }
                    archivedDialogues.append(session)
                    archivedDialogues.sort {
                        $0.date > $1.date
                    }
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
