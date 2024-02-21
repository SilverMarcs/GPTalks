//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import Combine
import CoreData
import SwiftUI

enum ContentState: String, CaseIterable, Identifiable {
    case active = "Active"
    case archived = "Archived"
    case images = "Images"
    
    var id: Self { self }
    
    var image : String {
        switch self {
            case .active:
                return "tray.full"
            case .archived:
                return "archivebox"
            case .images:
                return "photo"
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
                case .active:
                    activeDialogues = allDialogues.filter { !$0.isArchive }
                    break
                case .images:
                    // Update your view model or perform actions for the images state
                    break
            }
        }
    }
    
    var activeDialogues: [DialogueSession] = []

    var archivedDialogues: [DialogueSession] = []

    var isArchivedSelected: Bool = false
    
    var selectedState: ContentState = .active

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
                    case .active:
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
                    case .images:
                        break
                }
            } else {
                
                switch selectedState {
                    case .archived:
                        archivedDialogues = allDialogues.filter { $0.isArchive }
                        break
                    case .active:
                        activeDialogues = allDialogues.filter { !$0.isArchive }
                        break
                    case .images:
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
            case .active:
                return activeDialogues.isEmpty  || (!searchText.isEmpty && activeDialogues.isEmpty)
            case .images:
                return true
        }
    }

    var currentDialogues: [DialogueSession] {
        switch selectedState {
            case .archived:
            return archivedDialogues
            case .active:
            return activeDialogues
            case .images:
                return []
        }
    }
    
    var placeHolderText: String {
        switch selectedState {
            case .archived:
                return (!searchText.isEmpty && archivedDialogues.isEmpty) ? "No Search Results" : "No archived chats"
            case .active:
                return (!searchText.isEmpty && activeDialogues.isEmpty) ? "No Search Results" : "No active chats"
            case .images:
                return "Generate Images"
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
            selectedState = .active
        } else {
            isArchivedSelected.toggle()
            selectedState = .archived
        }
    }
    
    func tggleImageAndChat() {
        if selectedState == .images {
            selectedState = .active
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
            case .active:
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
        selectedState = .active

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
