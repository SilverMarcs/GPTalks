//
//  SessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftData
import SwiftUI

struct SessionList: View {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var providerManager = ProviderManager.shared

    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    @Query var sessions: [Session]

    @State var showSettings: Bool = false
    @State private var prevCount = 0

    init(
        sort: SortDescriptor<Session> = SortDescriptor(
            \Session.date, order: .reverse), searchString: String
    ) {
        _sessions = Query(
            filter: #Predicate {
                if searchString.isEmpty {
                    return true
                } else {
                    return $0.title.localizedStandardContains(searchString)
                }
            }, sort: [sort], animation: .default)
    }

    var body: some View {
        @Bindable var sessionVM = sessionVM

        SessionSearch("Search", text: $sessionVM.searchText) {
            sessionVM.searchText = ""
        }
        .padding(.horizontal, 10)

        ScrollViewReader { proxy in

            List(selection: $sessionVM.selections) {
                ForEach(sessions, id: \.self) { session in
                    SessionListItem(session: session)
                }
                .onDelete(perform: deleteItems)
            }
            .onChange(of: sessions.count) {
                if sessions.count > prevCount {
                    if let first = sessions.first {
                        sessionVM.selections = [first]
                        proxy.scrollTo(first, anchor: .top)
                    }
                }
            }
            .onAppear {
                if let first = sessions.first {
                    DispatchQueue.main.async {
                        sessionVM.selections = [first]
                    }
                }
            }
            .toolbar {
                toolbarItems
            }
            .popover(isPresented: $showSettings) {
                SettingsView()
                    .modelContainer(modelContext.container)
            }
        }
    }

    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        #if os(iOS)
            ToolbarItem(placement: .leading) {
                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
            }
        #endif
        ToolbarItem {
            Spacer()
        }

        ToolbarItem {
            Button(action: addItem) {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }

    private func addItem() {
        let provider: Provider
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            provider = defaultProvider
        } else if let firstProvider = providers.first {
            provider = firstProvider
        } else {
            return
        }

        let config = SessionConfig(
            provider: provider, model: provider.chatModel)

        let newItem = Session(config: config)

        withAnimation {
            modelContext.insert(newItem)
        }
        sessionVM.selections = [newItem]

        do {
            try modelContext.save()
        } catch {
            print("Failed to add Session")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}

#Preview {
    SessionList(
        sort: SortDescriptor(\Session.date, order: .reverse), searchString: ""
    )
    .frame(width: 400)
    .modelContainer(for: Session.self, inMemory: true)
    .environment(SessionVM())
}
