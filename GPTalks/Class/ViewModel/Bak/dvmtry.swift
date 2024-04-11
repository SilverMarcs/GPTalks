////
////  DialogueStore.swift
////  GPTalks
////
////  Created by Zabir Raihan on 10/12/2023.
////
//
//import CoreData
//import SwiftUI
//
//enum ContentState: String, CaseIterable, Identifiable {
//    case recent = "Recent"
//    case starred = "Starred"
//    case all = "Active"   // includes starred
//    case images = "Images"
//    case speech = "Speech"
//    
//    var id: Self { self }
//    
//    var image : String {
//        switch self {
//            case .recent:
//                "tray.fill"
//            case .all:
//                "tray.2"
//            case .starred:
//                "star.fill"
//            case .images:
//                "photo"
//            case .speech:
//                "waveform"
//        }
//    }
//}
//
//@Observable class DialogueViewModel {
//    private let viewContext: NSManagedObjectContext
//    
//    var allDialogues: [DialogueSession] = []
//    {
//        didSet {
//            switch selectedState {
//                case .starred:
//                activeDialogues = allDialogues.filter { $0.isArchive }
//                    break
//            case .recent, .images, .speech, .all:
//                activeDialogues = allDialogues
//                    break
//            }
//        }
//    }
//    
//
//    var activeDialogues: [DialogueSession] = []
//
////    var starredDialogues: [DialogueSession] = []
//
//    var isArchivedSelected: Bool = false
//    
//    var selectedState: ContentState = .recent {
//        didSet {
//            switch selectedState {
//            case .recent, .all:
//                activeDialogues = allDialogues
//                if selectedDialogue == nil {
//                    selectedDialogue = activeDialogues.first
//                }
//            case .starred:
//                activeDialogues = allDialogues.filter { $0.isArchive }
//                break
//            case .images, .speech:
//                selectedDialogue = nil
//            @unknown default:
//                break
//            }
//        }
//    }
//    
//    var searchText: String = "" {
//        didSet {
//            if !searchText.isEmpty {
//                activeDialogues = filterDialogues(matching: searchText, from: allDialogues)
//            } else {
//                switch selectedState {
//                    case .starred:
//                    activeDialogues = allDialogues.filter { $0.isArchive }
//                    break
//                case .recent, .images, .speech, .all:
//                    activeDialogues = allDialogues
//                        break
//                }
//            }
//        }
//    }
//
//    var selectedDialogue: DialogueSession?
//
//    var shouldShowPlaceholder: Bool {
//        return activeDialogues.isEmpty  || (!searchText.isEmpty && activeDialogues.isEmpty)
//    }
//
//    var currentDialogues: [DialogueSession] {
//        switch selectedState {
//        case .starred, .all:
//            activeDialogues
//        case .recent, .speech, .images:
//            #if os(iOS)
//            Array(activeDialogues.prefix(8))
//            #else
//            Array(activeDialogues.prefix(11))
//            #endif
//        }
//    }
//    
//    var placeHolderText: String {
//        let noSearchResult = "No Search Results"
//        let noActiveChats = "No Active Chats"
//        let noStarredChats = "No Starred Chats"
//        
//        // If there's no search text or there are active dialogues, no specific placeholder is needed.
//        guard !searchText.isEmpty && activeDialogues.isEmpty else {
//            return ""
//        }
//        
//        // Determine the placeholder based on the selected state.
//        switch selectedState {
//            case .starred:
//                return noStarredChats
//            case .recent, .images, .speech, .all:
//                return noActiveChats
//        }
//    }
//    
//    init(context: NSManagedObjectContext) {
//        viewContext = context
//        fetchDialogueData()
//    }
//
//    func fetchDialogueData(firstTime: Bool = true) {
//        do {
//            let fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
//
//            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }
//            
//            activeDialogues = allDialogues
//
//            #if os(macOS)
//                if firstTime {
//                    selectedDialogue = allDialogues.first
//                }
//            #endif
//        } catch {
//            print("DEBUG: Some error occured while fetching")
//        }
//    }
//    
//    func filterDialogues(matching searchText: String, from dialogues: [DialogueSession]) -> [DialogueSession] {
//        dialogues.filter { dialogue in
//            let isContentMatch = dialogue.conversations.contains { conversation in
//                conversation.content.localizedCaseInsensitiveContains(searchText)
//            }
//            let isTitleMatch = dialogue.title.localizedCaseInsensitiveContains(searchText)
//            return isContentMatch || isTitleMatch
//        }
//    }
//
//    func toggleArchivedStatus() {
//        isArchivedSelected.toggle()
//    }
//    
//    func toggleChatTypes() {
//        if isArchivedSelected {
//            isArchivedSelected.toggle()
//            selectedState = .recent
//        } else {
//            isArchivedSelected.toggle()
//            selectedState = .starred
//        }
//    }
//    
//    func tggleImageAndChat() {
//        if selectedState == .images {
//            selectedState = .recent
//        } else {
//            selectedState = .images
//        }
//    }
//
////    func toggleArchive(session: DialogueSession) {
////        session.toggleArchive()
////
////        switch selectedState {
////        case .starred:
////            activeDialogues = allDialogues.filter { $0.isArchive }
////                break
////        case .recent, .all, .images, .speech:
////                break
////        }
////    }
//    
//    func toggleArchive(session: DialogueSession) {
//        session.toggleArchive()
//        
//        switch selectedState {
//        case .starred:
////            if session.isArchive {
////                // If the chat is starred and the current state is .starred, add it to activeDialogues
////                activeDialogues = allDialogues.filter { $0.isArchive }
////            } else {
//                // If the chat is unstarred and the current state is .starred, remove it from activeDialogues
//                activeDialogues.removeAll { $0.id == session.id }
////            }
//        case .recent, .all, .images, .speech:
//            if session.isArchive {
//                // If the chat is starred and the current state is .recent or .all, keep it in activeDialogues
//                break
//            } else {
//                // If the chat is unstarred and the current state is .recent or .all, keep it in activeDialogues
//                break
//            }
////        case .images, .speech:
////            break
//        }
//    }
//    
//    func addDialogue(conversations: [Conversation] = []) {
//        if selectedState != .recent {
//            selectedState = .recent
//        }
//
//        let newItem = DialogueData(context: viewContext)
//        newItem.id = UUID()
//        newItem.date = Date()
//
//        if !conversations.isEmpty {
//            let conversationsSet = NSSet(array: conversations.map { conversation in
//                Conversation.createConversationData(from: conversation, in: viewContext)
//            })
//            newItem.conversations = conversationsSet
//        }
//
//        do {
//            newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration())
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        save()
//
//        if let session = DialogueSession(rawData: newItem) {
//            withAnimation {
//                allDialogues.insert(session, at: 0)
//                selectedDialogue = session
//            }
//        }
//    }
//
//    func deleteDialogue(_ session: DialogueSession) {
//        if selectedDialogue == session {
//            selectedDialogue = nil
//        }
//
//        withAnimation {
//            self.allDialogues.removeAll {
//                $0.id == session.id
//            }
//        }
//
//        if let item = session.rawData {
//            viewContext.delete(item)
//        }
//
//        save()
//    }
//
//    private func save() {
//        do {
//            try PersistenceController.shared.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
//}
