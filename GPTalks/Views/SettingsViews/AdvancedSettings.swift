//
//  AdvancedSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2024.
//

import SwiftUI
import SwiftData
import CryptoKit

struct AdvancedSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query var providers: [Provider]
    
    @State private var isExportingProvider = false
    @State private var isImportingProvider = false
    @State private var encryptionPassphrase = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                if !providers.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(providers, id: \.self) { provider in
                            VStack {
                                ProviderImage(provider: provider, scale: .large)
                                
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
                TextField("Encryption Passphrase:", text: $encryptionPassphrase)
                
                HStack {
                    Button {
                        isExportingProvider = true
                    } label: {
                        Label("Backup", systemImage: "square.and.arrow.up")
                            .labelStyle(.titleAndIcon)
                    }
                    .fileExporter(
                        isPresented: $isExportingProvider,
                        document: ProvidersDocument(providers: providers),
                        contentType: .json,
                        defaultFilename: "providers_backup_encrypted"
                    ) { result in
                        switch result {
                        case .success(let url):
                            do {
                                try encryptFile(at: url, passphrase: encryptionPassphrase)
                                alertMessage = "Backup saved to: \(url.path)"
                            } catch {
                                alertMessage = "Error encrypting backup: \(error.localizedDescription)"
                            }
                        case .failure(let error):
                            alertMessage = "Error saving backup: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                    
                    Spacer()
                    Text("|")
                        .foregroundStyle(.secondary)
                    Spacer()
                    
                    Button {
                        isImportingProvider = true
                    } label: {
                        Label("Restore", systemImage: "square.and.arrow.down")
                            .labelStyle(.titleAndIcon)
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
                                let decryptedData = try decryptFile(at: url, passphrase: encryptionPassphrase)
                                let restoredProviders = try JSONDecoder().decode([ProviderBackup].self, from: decryptedData)
                                
                                var restoredCount = 0
                                for restoredProvider in restoredProviders {
                                    if let existingProvider = providers.first(where: { $0.name.lowercased() == restoredProvider.name.lowercased() }) {
                                        existingProvider.apiKey = restoredProvider.apiKey
                                    } else {
                                        modelContext.insert(restoredProvider.toProvider())
                                        restoredCount += 1
                                    }
                                }
                                alertMessage = "Restore successful! Restored \(restoredCount) provider(s)."
                            } catch {
                                alertMessage = "Error restoring backup: Check passphrase or file integrity."
                            }
                        case .failure(let error):
                            alertMessage = "Error selecting file: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                }
            } footer: {
                SectionFooterView(text: "Enter the same passphrase when restoring the backup.")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Advanced Settings")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func encryptFile(at url: URL, passphrase: String) throws {
        let data = try Data(contentsOf: url)
        let symmetricKey = generateSymmetricKey(from: passphrase)
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        let encryptedData = sealedBox.combined
        try encryptedData?.write(to: url)
    }
    
    func decryptFile(at url: URL, passphrase: String) throws -> Data {
        let data = try Data(contentsOf: url)
        let symmetricKey = generateSymmetricKey(from: passphrase)
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
    
    func generateSymmetricKey(from passphrase: String) -> SymmetricKey {
        let keyData = Data(passphrase.utf8)
        let hashedData = SHA256.hash(data: keyData)
        return SymmetricKey(data: hashedData)
    }
}

#Preview {
    AdvancedSettings()
}
