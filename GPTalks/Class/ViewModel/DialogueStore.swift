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
    @Published var dialogues: [DialogueSession] = []
    @Published var searchText: String = ""
    @Published var filteredDialogues: [DialogueSession] = []
    private let viewContext: NSManagedObjectContext

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

    func fetchDialogueData() {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            dialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }

    func addDialogue() {
        let session = DialogueSession()
        dialogues.insert(session, at: 0)

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
        dialogues.removeAll {
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
