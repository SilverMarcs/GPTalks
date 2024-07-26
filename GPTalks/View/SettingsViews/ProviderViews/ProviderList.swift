//
//  ProviderList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderList: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Provider.order) var providers: [Provider]
    @ObservedObject var providerManager = ProviderManager.shared
    
    @State var selectedProvider: Provider?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportURL: URL?
    
    var body: some View {
        #if os(macOS)
        NavigationStack {
            Form {
                content
            }
            .formStyle(.grouped)
        }
        #else
        NavigationStack {
            content
        }
        #endif
    }
    
    var content: some View {
        List(selection: $selectedProvider) {
            ForEach(providers, id: \.self) { provider in
                NavigationLink(destination: ProviderDetail(provider: provider)) {
                    ProviderRow(provider: provider)
                }
            }
            .onDelete(perform: deleteProviders)
            .onMove(perform: move)
        }
        .navigationTitle("Providers")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            backupButtons

            addButton
        }
    }
    
    private var backupButtons: some View {
        Menu {
            exportButton
            
            importButton
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
        .menuStyle(SimpleIconOnly())
    }
    
    private var addButton: some View {
        Menu {
            ForEach(ProviderType.allCases, id: \.self) { type in
                Button(action: { addProvider(type: type) }) {
                    Text(type.name)
                }
            }
        } label: {
            Label("Create Provider", systemImage: "plus")
        }
        .menuStyle(SimpleIconOnly())
    }
    
    private func addProvider(type: ProviderType) {
        let newProvider = Provider.factory(type: type)
        
        withAnimation {
            for provider in providers {
                provider.order += 1
            }
            
            newProvider.order = 0
            modelContext.insert(newProvider)
        } completion: {
            selectedProvider = newProvider
            try? modelContext.save()
        }
    }
    
    private func deleteProviders(offsets: IndexSet) {
        withAnimation {
            let defaultProviderID = providerManager.defaultProvider
            var providersToDelete = offsets
            // Check if any of the selected providers is the default provider
            for index in offsets {
                if providers[index].id.uuidString == defaultProviderID && providers[index].name == "OpenAI" {
                    // Remove the default provider from the deletion set
                    providersToDelete.remove(index)
                }
            }
            // Delete the remaining providers
            for index in providersToDelete {
                modelContext.delete(providers[index])
            }
        } completion: {
            try? modelContext.save()
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var updatedProviders = providers
        updatedProviders.move(fromOffsets: source, toOffset: destination)
        
        for (index, provider) in updatedProviders.enumerated() {
            withAnimation {
                provider.order = index
            }
        }
        
        try? modelContext.save()
    }
    
    private var exportButton: some View {
        Button {
            isExporting = true
        } label: {
            Label("Backup", systemImage: "square.and.arrow.up")
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ProvidersDocument(providers: providers),
            contentType: .json,
            defaultFilename: "providers_backup"
        ) { result in
            switch result {
            case .success(let url):
                print("Backup saved to: \(url.path)")
            case .failure(let error):
               print("Error saving backup: \(error.localizedDescription)")
            }
        }
    }
    
    private var importButton: some View {
        Button {
            isImporting = true
        } label: {
            Label("Restore", systemImage: "square.and.arrow.down")
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    let restoredProviders = try restoreProviders(from: url)
                    for provider in restoredProviders {
                        if !providers.contains(where: { $0.name == provider.name && $0.id == provider.id }) {
                            modelContext.insert(provider)
                        }
                    }
                } catch {
                   print("Error restoring backup: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ProviderList()
        .modelContainer(for: Provider.self, inMemory: true)
}
