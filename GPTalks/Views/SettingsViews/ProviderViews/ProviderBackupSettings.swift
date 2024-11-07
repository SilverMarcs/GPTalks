//
//  ProviderBackupSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderBackupSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query var providers: [Provider]
    
    @State private var isExportingProvider = false
    @State private var isImportingProvider = false
    
    var body: some View {
        Menu {
            Button {
                isExportingProvider = true
            } label: {
                Label("Backup", systemImage: "square.and.arrow.up")
                    .labelStyle(.titleAndIcon)
            }

            Button {
                isImportingProvider = true
            } label: {
                Label("Restore", systemImage: "square.and.arrow.down")
                    .labelStyle(.titleAndIcon)
            }
        } label: {
            Label("Backup", systemImage: "opticaldiscdrive")
                .labelStyle(.titleOnly)
        }
        .fileExporter(
            isPresented: $isExportingProvider,
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
        .fileImporter(
            isPresented: $isImportingProvider,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    let restoredProviders = try restoreProviders(from: url)
                    for restoredProvider in restoredProviders {
                        if let existingProvider = providers.first(where: { $0.name.lowercased() == restoredProvider.name.lowercased() }) {
                            existingProvider.apiKey = restoredProvider.apiKey
                        } else {
                            modelContext.insert(restoredProvider)
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
    
    func restoreProviders(from url: URL) throws -> [Provider] {
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "FileAccessError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the security-scoped resource."])
        }
        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)
            let backups = try JSONDecoder().decode([ProviderBackup].self, from: data)
            return backups.map { $0.toProvider() }
        } catch {
            print("Error reading or decoding file: \(error)")
            throw error
        }
    }
}

#Preview {
    ProviderBackupSettings()
}
