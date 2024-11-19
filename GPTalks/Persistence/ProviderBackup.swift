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
    var models: [AIModelBackup]
    var chatModelCode: String
    var liteModelCode: String
    var imageModelCode: String
    var sttModelCode: String
    
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
        self.models = provider.models.map { AIModelBackup(from: $0) }
        self.chatModelCode = provider.chatModel.code
        self.liteModelCode = provider.liteModel.code
        self.imageModelCode = provider.imageModel.code
        self.sttModelCode = provider.sttModel.code
    }

    func toProvider() -> Provider {
        let models: [AIModel] = self.models.map { $0.toAIModel() }
        
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
            models: models,
            chatModel: models.first(where: { $0.code == self.chatModelCode }) ?? AIModel.gpt4,
            liteModel: models.first(where: { $0.code == self.liteModelCode }) ?? AIModel.gpt4,
            imageModel: models.first(where: { $0.code == self.imageModelCode }) ?? AIModel.dalle,
            sttModel: models.first(where: { $0.code == self.sttModelCode }) ?? AIModel.whisper
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
