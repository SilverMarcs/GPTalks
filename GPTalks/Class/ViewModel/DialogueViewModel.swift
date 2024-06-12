//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import CoreData
import SwiftUI

enum ContentState: String, CaseIterable, Identifiable {
    case chats = "Chats"
    case images = "Images"
    
    var id: Self { self }
    
    var image: String {
        switch self {
        case .chats:
            return "tray.2.fill"
        case .images:
            return "photo"
        }
    }
}

@Observable class DialogueViewModel {
    private let viewContext: NSManagedObjectContext
    
    var allDialogues: [DialogueSession] = []
    
    var isExpanded: Bool = false
    
    var selectedState: ContentState = .chats 
    {
        didSet {
            switch selectedState {
            case .chats:
                if selectedDialogues.isEmpty {
                    #if os(macOS)
                    if let first = allDialogues.first {
                        selectedDialogues.insert(first)
                    }
                    #endif
                }
            case .images:
                selectedDialogues = []
            }
        }
    }
    
    var searchText: String = ""
    
    var selectedDialogues: Set<DialogueSession> = []
    var selectedDialogue: DialogueSession?

    func deleteSelectedDialogues() {
        for session in selectedDialogues {
            deleteDialogue(session)
        }
        selectedDialogues.removeAll()
    }
    
    func toggleStarredDialogues() {
        for session in selectedDialogues {
            session.isArchive.toggle()
        }
    }
    
    var shouldShowPlaceholder: Bool {
        return (!searchText.isEmpty && currentDialogues.isEmpty) || currentDialogues.isEmpty
    }

    var currentDialogues: [DialogueSession] {
        if !searchText.isEmpty {
            return filterDialogues(matching: searchText, from: allDialogues)
        } else {    
            return Array(allDialogues.prefix(isExpanded ? allDialogues.count : 10))
        }
    }
    
    var placeHolderText: String {
        return allDialogues.isEmpty ? "Start a new chat" : "No Search Results"
    }
    
    init(context: NSManagedObjectContext) {
        viewContext = context
        fetchDialogueData()
    }

    func fetchDialogueData(firstTime: Bool = true) {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }
            
            if firstTime {
                    #if os(macOS)
                if let first = allDialogues.first {
                    selectedDialogues.insert(first)
                }
                    #endif
                }
            
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }
    
    func filterDialogues(matching searchText: String, from dialogues: [DialogueSession]) -> [DialogueSession] {
        dialogues.filter { dialogue in
            let isContentMatch = dialogue.conversations.contains { conversation in
                conversation.content.localizedCaseInsensitiveContains(searchText)
            }
            let isTitleMatch = dialogue.title.localizedCaseInsensitiveContains(searchText)
            return isContentMatch || isTitleMatch
        }
    }


    func moveUpChat(session: DialogueSession) {
        session.date = Date()
        session.save()
        
        if session.id == allDialogues.first?.id {
            return
        }
        
        let index = allDialogues.firstIndex { $0.id == session.id }
        if let index = index {
            withAnimation {
                allDialogues.remove(at: index)
                allDialogues.insert(session, at: 0)
            }
        }
    }
    
    func toggleImageAndChat() {
        if selectedState == .images {
            selectedState = .chats
        } else {
            selectedState = .images
        }
    }

    func addDialogue(conversations: [Conversation] = []) {
//        if let first = allDialogues.first {
//            if first.conversations.count == 0 {
//                selectedDialogues = [first]
//                return
//            }
//        }
        
        if selectedState != .chats {
            selectedState = .chats
        }

        let newItem = DialogueData(context: viewContext)
        newItem.id = UUID()
        newItem.date = Date()

        if !conversations.isEmpty {
            let conversationsSet = NSSet(array: conversations.map { conversation in
                Conversation.createConversationData(from: conversation, in: viewContext)
            })
            newItem.conversations = conversationsSet
        }

        do {
            newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration())
        } catch {
            print(error.localizedDescription)
        }

        save()

        if let session = DialogueSession(rawData: newItem) {
            withAnimation {
                allDialogues.insert(session, at: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
#if os(macOS)
                self.selectedDialogues = []
                self.selectedDialogues.insert(session)
#else
                self.selectedDialogue = session
#endif
            }
        }
    }
    
    func addToDB(dialogue: DialogueSession) {
        if selectedState != .chats {
            selectedState = .chats
        }

        
    }

    func deleteDialogue(_ session: DialogueSession) {
        if session.isArchive {
            return
        }
        
        if selectedDialogues.contains(where: { $0.id == session.id }) {
            selectedDialogues.remove(session)
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
