//
//  ProviderBackup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/07/2024.
//


import Foundation

struct ProviderBackup: Codable {
    var id: UUID
    var date: Date
    var order: Int
    var name: String
    var host: String
    var apiKey: String
    var type: ProviderType
    var color: String
    var isEnabled: Bool
    var chatModelCode: String
    var quickChatModelCode: String
    var titleModelCode: String
    var imageModelCode: String
    var models: [AIModelBackup]
    
    struct AIModelBackup: Codable {
        var id: UUID
        var order: Int
        var modelType: ModelType
        var code: String
        var name: String
        var isEnabled: Bool
    }
}

func backupProviders(_ providers: [Provider], to filename: String = "providers_backup.json") {
    let backups = providers.map { provider -> ProviderBackup in
        ProviderBackup(
            id: provider.id,
            date: provider.date,
            order: provider.order,
            name: provider.name,
            host: provider.host,
            apiKey: provider.apiKey,
            type: provider.type,
            color: provider.color,
            isEnabled: provider.isEnabled,
            chatModelCode: provider.chatModel.code,
            quickChatModelCode: provider.quickChatModel.code,
            titleModelCode: provider.titleModel.code,
            imageModelCode: provider.imageModel.code,
            models: provider.models.map { model in
                ProviderBackup.AIModelBackup(
                    id: model.id,
                    order: model.order,
                    modelType: model.modelType,
                    code: model.code,
                    name: model.name,
                    isEnabled: model.isEnabled
                )
            }
        )
    }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    do {
        let data = try encoder.encode(backups)
        let fileURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
        try data.write(to: fileURL)
        print("Backup saved to: \(fileURL.path)")
    } catch {
        print("Error saving backup: \(error.localizedDescription)")
    }
}

func restoreProviders(from filename: String = "providers_backup.json") -> [Provider] {
    let fileURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
    
    do {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let backups = try decoder.decode([ProviderBackup].self, from: data)
        
        return backups.map { backup in
            let models = backup.models.map { modelBackup in
                AIModel(
                    code: modelBackup.code,
                    name: modelBackup.name,
                    modelType: modelBackup.modelType,
                    order: modelBackup.order
                )
            }
            
            let provider = Provider(
                id: backup.id,
                date: backup.date,
                order: backup.order,
                name: backup.name,
                host: backup.host,
                apiKey: backup.apiKey,
                type: backup.type,
                color: backup.color,
                isEnabled: backup.isEnabled,
                chatModel: models.first(where: { $0.code == backup.chatModelCode }) ?? AIModel(code: backup.chatModelCode, name: ""),
                quickChatModel: models.first(where: { $0.code == backup.quickChatModelCode }) ?? AIModel(code: backup.quickChatModelCode, name: ""),
                titleModel: models.first(where: { $0.code == backup.titleModelCode }) ?? AIModel(code: backup.titleModelCode, name: ""),
                imageModel: models.first(where: { $0.code == backup.imageModelCode }) ?? AIModel(code: backup.imageModelCode, name: ""),
                models: models
            )
            
            // Set the provider for each model
            provider.models.forEach { $0.provider = provider }
            
            return provider
        }
    } catch {
        print("Error restoring backup: \(error.localizedDescription)")
        return []
    }
}
