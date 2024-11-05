//
//  BackupSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData

struct BackupSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query var sessions: [Chat]
    @Query var providers: [Provider]
    
    @State private var isExportingProvider = false
    @State private var isImportingProvider = false

    @State private var isExportingSession = false
    @State private var isImportingSession = false
    
    var body: some View {
        Form {
            Section {
                importButton {
                    isImportingSession = true
                }
                .sessionImporter(isImporting: $isImportingSession, modelContext: modelContext, existingSessions: sessions)
                
                exportButton {
                    isExportingSession = true
                }
                .sessionExporter(isExporting: $isExportingSession, sessions: sessions)
            } header: {
                Text("Sessions")
            } footer: {
                SectionFooterView(text: "Session configuration and images are not backed up")
            }
            
            Section {
                importButton {
                    isImportingProvider = true
                }
                .providerImporter(isImporting: $isImportingProvider, modelContext: modelContext, providers: providers)
                
                exportButton {
                    isExportingProvider = true
                }
                .providerExporter(isExporting: $isExportingProvider, providers: providers)
            } header: {
                Text("Providers")
            } footer: {
                SectionFooterView(text: "API Keys will be stored in plaintext")
            }
        }
        .navigationTitle("Backup")
        .toolbarTitleDisplayMode(.inline)
        .buttonStyle(.plain)
        .formStyle(.grouped)
    }
    
    private func exportButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Label("Backup", systemImage: "square.and.arrow.up")
        }
    }

    private func importButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Label("Restore", systemImage: "square.and.arrow.down")
        }
    }
}

#Preview {
    BackupSettings()
}
