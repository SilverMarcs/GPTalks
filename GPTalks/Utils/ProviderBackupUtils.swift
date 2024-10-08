//
//  ProviderBackupUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct FileExporterModifier: ViewModifier {
    @Binding var isExporting: Bool
    let providers: [Provider]
    
    func body(content: Content) -> some View {
        content
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
}

struct FileImporterModifier: ViewModifier {
    @Binding var isImporting: Bool
    let modelContext: ModelContext
    let providers: [Provider]
    
    func body(content: Content) -> some View {
        content
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
}

extension View {
    func providerExporter(isExporting: Binding<Bool>, providers: [Provider]) -> some View {
        self.modifier(FileExporterModifier(isExporting: isExporting, providers: providers))
    }
    
    func providerImporter(isImporting: Binding<Bool>, modelContext: ModelContext, providers: [Provider]) -> some View {
        self.modifier(FileImporterModifier(isImporting: isImporting, modelContext: modelContext, providers: providers))
    }
}
