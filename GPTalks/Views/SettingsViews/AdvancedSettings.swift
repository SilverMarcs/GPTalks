//
//  AdvancedSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2024.
//

import SwiftUI
import SwiftData

struct AdvancedSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query var providers: [Provider]
    
    @State private var isExportingProvider = false
    @State private var isImportingProvider = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                if !providers.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(providers, id: \.self) { provider in
                            VStack {
                                ProviderImage(provider: provider, frame: 30, scale: .large)
                                
                                Text(provider.name)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                } else {
                    Text("No providers found.")
                        .italic()
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Backup & Restore Providers")
            }
            
            Section {
                #if os(macOS)
                LabeledContent("\(providers.count) Providers will be backed up.") {
                    HStack {
                        exportButton
                        importButton
                    }
                }
                #else
                exportButton
                importButton
                #endif
            } footer: {
                SectionFooterView(text: "API Keys will be stored in plaintext")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Advanced Settings")
        .toolbarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var importButton: some View {
        Button {
            isImportingProvider = true
        } label: {
            Label("Restore", systemImage: "square.and.arrow.down")
                .labelStyle(.titleOnly)
        }
        .disabled(providers.isEmpty)
        .fileImporter(
            isPresented: $isImportingProvider,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    guard url.startAccessingSecurityScopedResource() else {
                         throw NSError(domain: "FileAccessError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the security-scoped resource."])
                     }
                     defer {
                         url.stopAccessingSecurityScopedResource()
                     }
                    
                    let data = try Data(contentsOf: url)
                    let restoredProviders = try JSONDecoder().decode([ProviderBackup].self, from: data)
                    
                    var restoredCount = 0
                    for restoredProvider in restoredProviders {
                        if let existingProvider = providers.first(where: { $0.name.lowercased() == restoredProvider.name.lowercased() }) {
                            existingProvider.apiKey = restoredProvider.apiKey
                            existingProvider.isEnabled = restoredProvider.isEnabled
                            
                            // Add any missing models from restoredProvider to existingProvider
                            for restoredModel in restoredProvider.models {
                                if !existingProvider.models.contains(where: { $0.code == restoredModel.code }) {
                                    let newModel = restoredModel.toAIModel()
                                    existingProvider.models.append(newModel)
                                }
                            }

                            // Set the existing provider's models to match the restored provider's models
                            if let chatModel = existingProvider.models.first(where: { $0.code == restoredProvider.chatModelCode }) {
                                existingProvider.chatModel = chatModel
                            }
                            if let liteModel = existingProvider.models.first(where: { $0.code == restoredProvider.liteModelCode }) {
                                existingProvider.liteModel = liteModel
                            }
                            if let imageModel = existingProvider.models.first(where: { $0.code == restoredProvider.imageModelCode }) {
                                existingProvider.imageModel = imageModel
                            }
                            if let sttModel = existingProvider.models.first(where: { $0.code == restoredProvider.sttModelCode }) {
                                existingProvider.sttModel = sttModel
                            }
                            
                        } else {
                            modelContext.insert(restoredProvider.toProvider())
                            restoredCount += 1
                        }
                    }
                    alertMessage = "Restore successful! Restored \(restoredCount) provider(s)."
                } catch {
                    alertMessage = "Error restoring backup: \(error.localizedDescription)"
                }
            case .failure(let error):
                alertMessage = "Error selecting file: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
    
    var exportButton: some View {
        Button {
            isExportingProvider = true
        } label: {
            Label("Backup", systemImage: "square.and.arrow.up")
                .labelStyle(.titleOnly)
        }
        .disabled(providers.isEmpty)
        .fileExporter(
            isPresented: $isExportingProvider,
            document: ProvidersDocument(providers: providers),
            contentType: .json,
            defaultFilename: "providers_backup"
        ) { result in
            switch result {
            case .success(let url):
                alertMessage = "Backup saved to: \(url.path)"
            case .failure(let error):
                alertMessage = "Error saving backup: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
}

#Preview {
    AdvancedSettings()
}
