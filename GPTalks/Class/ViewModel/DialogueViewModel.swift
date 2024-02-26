//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import CoreData
import SwiftUI

enum ContentState: String, CaseIterable, Identifiable {
    case recent = "Recents"
    case all = "Active"   //excludes archived
    case archived = "Archived"
    case images = "Images"
    
    var id: Self { self }
    
    var image : String {
        switch self {
            case .recent:
                "tray.full"
            case .all:
                "tray.2"
            case .archived:
                "archivebox"
            case .images:
                "photo"
        }
    }
}

@Observable class DialogueViewModel {
    private let viewContext: NSManagedObjectContext

    var allDialogues: [DialogueSession] = [] {
        didSet {
            switch selectedState {
                case .archived:
                    archivedDialogues = allDialogues.filter { $0.isArchive }
                    break
            case .recent, .images, .all:
                    activeDialogues = allDialogues.filter { !$0.isArchive }
                    break
            }
        }
    }
    
    var activeDialogues: [DialogueSession] = []

    var archivedDialogues: [DialogueSession] = []

    var isArchivedSelected: Bool = false
    
    var selectedState: ContentState = .recent

    var searchText: String = "" {
        didSet {
            if !searchText.isEmpty {
                switch selectedState {
                    case .archived:
                        let filteredDialogues = allDialogues.filter { dialogue in
                            let isContentMatch = dialogue.conversations.contains { conversation in
                                conversation.content.localizedCaseInsensitiveContains(searchText)
                            }
                            return isContentMatch
                        }
                    #if os(macOS) // macos has a bug where if no matches, search bar disappears
                        archivedDialogues = filteredDialogues.isEmpty ? allDialogues : filteredDialogues
                    #else
                        archivedDialogues = filteredDialogues
                    #endif
                        break
                case .recent, .images, .all:
                        let filteredDialogues = allDialogues.filter { dialogue in
                            let isContentMatch = dialogue.conversations.contains { conversation in
                                conversation.content.localizedCaseInsensitiveContains(searchText)
                            }
                            return isContentMatch
                        }
                    #if os(macOS) // macos has a bug where if no matches, search bar disappears
                        activeDialogues = filteredDialogues.isEmpty ? allDialogues : filteredDialogues
                    #else
                        activeDialogues = filteredDialogues
                    #endif
                        break
                }
            } else {
                
                switch selectedState {
                    case .archived:
                        archivedDialogues = allDialogues.filter { $0.isArchive }
                        break
                case .recent, .images, .all:
                        activeDialogues = allDialogues.filter { !$0.isArchive }
                        break
                }
            }
        }
    }

    var selectedDialogue: DialogueSession?

    init(context: NSManagedObjectContext) {
        viewContext = context
        fetchDialogueData()
    }

    var shouldShowPlaceholder: Bool {
        switch selectedState {
            case .archived:
                return archivedDialogues.isEmpty || (!searchText.isEmpty && archivedDialogues.isEmpty)
            case .recent, .images, .all:
                return activeDialogues.isEmpty  || (!searchText.isEmpty && activeDialogues.isEmpty)
        }
    }

    var currentDialogues: [DialogueSession] {
        switch selectedState {
            case .archived:
                archivedDialogues
            case .all:
                activeDialogues
            case .recent, .images:
            #if os(iOS)
            Array(activeDialogues.prefix(6))
            #else
            Array(activeDialogues.prefix(10))
            #endif
        }
    }
    
    var placeHolderText: String {
        switch selectedState {
            case .archived:
                return (!searchText.isEmpty && archivedDialogues.isEmpty) ? "No Search Results" : "No archived chats"
        case .recent, .images, .all:
                return (!searchText.isEmpty && activeDialogues.isEmpty) ? "No Search Results" : "No active chats"
        }
    }

    func fetchDialogueData(firstTime: Bool = true) {
        do {
            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }

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
    }
    
    func toggleChatTypes() {
        if isArchivedSelected {
            isArchivedSelected.toggle()
            selectedState = .recent
        } else {
            isArchivedSelected.toggle()
            selectedState = .archived
        }
    }
    
    func tggleImageAndChat() {
        if selectedState == .images {
            selectedState = .recent
        } else {
            selectedState = .images
        }
    }

    func toggleArchive(session: DialogueSession) {
        session.toggleArchive()
        
        switch selectedState {
            case .archived:
            withAnimation {
                archivedDialogues.removeAll {
                    $0.id == session.id
                }
                activeDialogues.append(session)
                activeDialogues.sort {
                    $0.date > $1.date
                }
            }
                break
            case .recent, .all:
            withAnimation {
                activeDialogues.removeAll {
                    $0.id == session.id
                }
                archivedDialogues.append(session)
                archivedDialogues.sort {
                    $0.date > $1.date
                }
            }
            
                break
            case .images:
                break
        }
    }

    func addDialogue(conversations: [Conversation] = []) {
        selectedState = .recent

        let session = DialogueSession()
        
        if !conversations.isEmpty {
            session.conversations = conversations
        }
        
        withAnimation {
            allDialogues.insert(session, at: 0)
            selectedDialogue = session
        }

        let newItem = DialogueData(context: viewContext)
        newItem.id = session.id
        newItem.date = session.date
        
        if !conversations.isEmpty {
            // Convert your array of Conversation objects to NSSet and assign it to newItem.conversations
            let conversationsSet = NSSet(array: conversations.map { conversation in
                // Assuming you need to create a ConversationData object for each Conversation
                let data = ConversationData(context: viewContext)
                data.id = conversation.id
                data.date = conversation.date
                data.role = conversation.role
                data.content = conversation.content
                data.base64Image = conversation.base64Image
                return data
            })
            newItem.conversations = conversationsSet
        }

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
