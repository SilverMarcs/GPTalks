//
//  FileHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 24/07/2024.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct FileHelper {
    static func deleteFile(at path: String) {
        do {
            #if os(macOS)
            if let fileURL = URL(string: path) {
                try Foundation.FileManager.default.removeItem(at: fileURL)
            }
            #else
            let documentsDirectory = try Foundation.FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(path)
            try Foundation.FileManager.default.removeItem(at: fileURL)
            #endif
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
}

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
                        for provider in restoredProviders {
                            if !providers.contains(where: { $0.name.lowercased() == provider.name.lowercased() || $0.id == provider.id || $0.apiKey.lowercased() == provider.apiKey.lowercased() }) {
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

// Extension to make it easier to use these modifiers
extension View {
    func fileExporter(isExporting: Binding<Bool>, providers: [Provider]) -> some View {
        self.modifier(FileExporterModifier(isExporting: isExporting, providers: providers))
    }
    
    func fileImporter(isImporting: Binding<Bool>, modelContext: ModelContext, providers: [Provider]) -> some View {
        self.modifier(FileImporterModifier(isImporting: isImporting, modelContext: modelContext, providers: providers))
    }
}
