//
//  ProviderBackup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/07/2024.
//


import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProviderBackup: Codable {
    var id: UUID
    var date: Date
    var name: String
    var host: String
    var apiKey: String
    var type: ProviderType
    var schema: HTTPScheme
    var color: String
    var isEnabled: Bool
    var chatModelCode: String
    var quickChatModelCode: String
    var titleModelCode: String
    var imageModelCode: String
    var toolImageModelCode: String
    var chatModels: [AIModelBackup]
    var imageModels: [AIModelBackup]
    var sttModels: [AIModelBackup]
    
    struct AIModelBackup: Codable {
        var id: UUID
        var code: String
        var name: String
        var type: ModelType
    }
}

extension ProviderBackup {
    init(from provider: Provider) {
        self.id = UUID()
        self.date = Date()
        self.name = provider.name
        self.host = provider.host
        self.apiKey = provider.apiKey
        self.type = provider.type
        self.schema = provider.scheme
        self.color = provider.color
        self.isEnabled = provider.isEnabled
        self.chatModelCode = provider.chatModel.code
        self.quickChatModelCode = provider.quickChatModel.code
        self.titleModelCode = provider.titleModel.code
        self.imageModelCode = provider.imageModel.code
        self.toolImageModelCode = provider.toolImageModel.code
        self.chatModels = provider.chatModels.map { AIModelBackup(from: $0) }
        self.imageModels = provider.imageModels.map { AIModelBackup(from: $0) }
        self.sttModels = provider.sttModels.map { AIModelBackup(from: $0) }
    }

    func toProvider() -> Provider {
        let chatModels = self.chatModels.map { $0.toAIModel() }
        let imageModels = self.imageModels.map { $0.toAIModel() }
        let sttModels = self.sttModels.map { $0.toAIModel() }
        return Provider(
            id: UUID(),
            date: Date(),
            name: self.name,
            host: self.host,
            apiKey: self.apiKey,
            type: self.type,
            scheme: self.schema,
            color: self.color,
            isEnabled: self.isEnabled,
            chatModel: chatModels.first(where: { $0.code == self.chatModelCode }) ?? AIModel(code: self.chatModelCode, name: "", type: .chat),
            quickChatModel: chatModels.first(where: { $0.code == self.quickChatModelCode }) ?? AIModel(code: self.quickChatModelCode, name: "", type: .chat),
            titleModel: chatModels.first(where: { $0.code == self.titleModelCode }) ?? AIModel(code: self.titleModelCode, name: "", type: .chat),
            imageModel: imageModels.first(where: { $0.code == self.imageModelCode }) ?? AIModel(code: self.imageModelCode, name: "", type: .image),
            toolImageModel: imageModels.first(where: { $0.code == self.toolImageModelCode }) ?? AIModel(code: self.toolImageModelCode, name: "", type: .image),
            chatModels: chatModels,
            imageModels: imageModels,
            sttModel: sttModels.first(where: { $0.code == self.toolImageModelCode }) ?? AIModel(code: self.toolImageModelCode, name: "", type: .stt),
            sttModels: sttModels
        )
    }
}

extension ProviderBackup.AIModelBackup {
    init(from model: AIModel) {
        self.id = model.id
        self.code = model.code
        self.name = model.name
        self.type = model.type
    }

    func toAIModel() -> AIModel {
        AIModel(
            code: self.code,
            name: self.name,
            type: self.type
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
