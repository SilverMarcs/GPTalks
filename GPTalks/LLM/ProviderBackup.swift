//
//  ProviderBackup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/07/2024.
//


import Foundation
import SwiftUI
import UniformTypeIdentifiers

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
    var supportsImage: Bool
    var chatModelCode: String
    var quickChatModelCode: String
    var titleModelCode: String
    var imageModelCode: String
    var toolImageModelCode: String
    var chatModels: [AIModelBackup]
    var imageModels: [ImageModelBackup]
    
    struct AIModelBackup: Codable {
        var id: UUID
        var code: String
        var name: String
    }
    
    struct ImageModelBackup: Codable {
        var id: UUID
        var code: String
        var name: String
    }
}

extension ProviderBackup {
    init(from provider: Provider) {
        self.id = UUID()
        self.date = Date()
        self.order = provider.order
        self.name = provider.name
        self.host = provider.host
        self.apiKey = provider.apiKey
        self.type = provider.type
        self.color = provider.color
        self.isEnabled = provider.isEnabled
        self.supportsImage = provider.supportsImage
        self.chatModelCode = provider.chatModel.code
        self.quickChatModelCode = provider.quickChatModel.code
        self.titleModelCode = provider.titleModel.code
        self.imageModelCode = provider.imageModel.code
        self.toolImageModelCode = provider.toolImageModel.code
        self.chatModels = provider.chatModels.map { AIModelBackup(from: $0) }
        self.imageModels = provider.imageModels.map { ImageModelBackup(from: $0) }
    }

    func toProvider() -> Provider {
        let chatModels = self.chatModels.map { $0.toAIModel() }
        let imageModels = self.imageModels.map { $0.toAIModel() }
        return Provider(
            id: UUID(),
            date: Date(),
            order: self.order,
            name: self.name,
            host: self.host,
            apiKey: self.apiKey,
            type: self.type,
            color: self.color,
            isEnabled: self.isEnabled,
            supportsImage: self.supportsImage,
            chatModel: chatModels.first(where: { $0.code == self.chatModelCode }) ?? ChatModel(code: self.chatModelCode, name: ""),
            quickChatModel: chatModels.first(where: { $0.code == self.quickChatModelCode }) ?? ChatModel(code: self.quickChatModelCode, name: ""),
            titleModel: chatModels.first(where: { $0.code == self.titleModelCode }) ?? ChatModel(code: self.titleModelCode, name: ""),
            imageModel: imageModels.first(where: { $0.code == self.imageModelCode }) ?? ImageModel(code: self.imageModelCode, name: ""),
            toolImageModel: imageModels.first(where: { $0.code == self.toolImageModelCode }) ?? ImageModel(code: self.toolImageModelCode, name: ""),
            chatModels: chatModels,
            imageModels: imageModels,
            sttModel: STTModel(code: "", name: ""),
            sttModels: []
        )
    }
}

extension ProviderBackup.AIModelBackup {
    init(from model: ChatModel) {
        self.id = model.id
        self.code = model.code
        self.name = model.name
    }

    func toAIModel() -> ChatModel {
        ChatModel(
            code: self.code,
            name: self.name
        )
    }
}

extension ProviderBackup.ImageModelBackup {
    init(from model: ImageModel) {
        self.id = model.id
        self.code = model.code
        self.name = model.name
    }
    
    func toAIModel() -> ImageModel {
        ImageModel(
            code: self.code,
            name: self.name
        )
    }
}

struct ProvidersDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var providers: [Provider]

    init(providers: [Provider]) {
        self.providers = providers
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.providers = try JSONDecoder().decode([ProviderBackup].self, from: data).map { $0.toProvider() }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(providers.map { ProviderBackup(from: $0) })
        return FileWrapper(regularFileWithContents: data)
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
