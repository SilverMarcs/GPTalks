//
//  Provider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import GoogleGenerativeAI

@Model
class Provider {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var name: String = ""
    var host: String = ""
    @Attribute(.allowsCloudEncryption)
    var apiKey: String = ""
    
    var type: ProviderType
    var scheme: HTTPScheme
    var isPersistent: Bool = false  // added by the app by default and are not deletable
    var extraInfo: String = ""
    
    var color: String = "#00947A"
    var isEnabled: Bool = true
    
    @Relationship(deleteRule: .cascade)
    var chatModel: AIModel
    @Relationship(deleteRule: .cascade)
    var quickChatModel: AIModel
    @Relationship(deleteRule: .cascade)
    var titleModel: AIModel
    @Relationship(deleteRule: .cascade)
    var chatModels: [AIModel] = []
    
    @Relationship(deleteRule: .cascade)
    var imageModel: AIModel
    @Relationship(deleteRule: .cascade)
    var toolImageModel: AIModel
    @Relationship(deleteRule: .cascade)
    var imageModels: [AIModel] = []
    
    @Relationship(deleteRule: .cascade)
    var sttModel: AIModel
    @Relationship(deleteRule: .cascade)
    var sttModels: [AIModel] = []

    public init(id: UUID = UUID(),
                date: Date = Date(),
                name: String,
                host: String,
                apiKey: String,
                type: ProviderType,
                scheme: HTTPScheme,
                color: String,
                isEnabled: Bool,
                chatModel: AIModel,
                quickChatModel: AIModel,
                titleModel: AIModel,
                imageModel: AIModel,
                toolImageModel: AIModel,
                chatModels: [AIModel] = [],
                imageModels: [AIModel] = [],
                sttModel: AIModel,
                sttModels: [AIModel] = []) {
        self.id = id
        self.date = date
        self.name = name
        self.host = host
        self.apiKey = apiKey
        self.type = type
        self.scheme = scheme
        self.color = color
        self.isEnabled = isEnabled
        self.chatModel = chatModel
        self.quickChatModel = quickChatModel
        self.titleModel = titleModel
        self.imageModel = imageModel
        self.toolImageModel = toolImageModel
        self.chatModels = chatModels
        self.imageModels = imageModels
        self.sttModel = sttModel
        self.sttModels = sttModels
    }
    
    
    static func factory(type: ProviderType, isDummy: Bool = false) -> Provider {
        let demoImageModel = AIModel.dalle
        let demoSttModel = AIModel.whisper
        
        let allModels = type.getDefaultModels()

        var chatModels: [AIModel] = []
        var imageModels: [AIModel] = []
        var sttModels: [AIModel] = []

        for model in allModels {
            switch model.type {
            case .chat:
                chatModels.append(model)
            case .image:
                imageModels.append(model)
            case .stt:
                sttModels.append(model)
            }
        }
        
        
        let provider = Provider(
            name: type.name,
            host: type.defaultHost,
            apiKey: "",
            type: type,
            scheme: type.scheme,
            color: type.defaultColor,
            isEnabled: !isDummy,
            chatModel: chatModels.first!,
            quickChatModel: chatModels.first!,
            titleModel: chatModels.first!,
            imageModel: imageModels.first ?? demoImageModel,
            toolImageModel: imageModels.first ?? demoImageModel,
            chatModels: chatModels,
            imageModels: imageModels,
            sttModel: sttModels.first ?? demoSttModel,
            sttModels: sttModels
        )
        
        return provider
    }
    
    func addModel(_ model: GenericModel) {
        switch model.selectedModelType {
        case .chat:
            chatModels.append(AIModel(code: model.code, name: model.name, type: .chat))
        case .image:
            imageModels.append(AIModel(code: model.code, name: model.name, type: .image))
        case .stt:
            sttModels.append(AIModel(code: model.code, name: model.name, type: .stt))
        }
    }
}

enum HTTPScheme: String, Codable, CaseIterable {
    case http
    case https
}

extension Provider {
    func refreshModels() async -> [GenericModel] {
        let refreshedChatModels: [GenericModel] = await type.getService().refreshModels(provider: self)
        let newModels = refreshedChatModels.filter { model in
            !chatModels.contains(where: { $0.code == model.code }) || !imageModels.contains(where: { $0.code == model.code }) || !sttModels.contains(where: { $0.code == model.code })
        }
        
        return newModels.map { chatModel in
            GenericModel(code: chatModel.code, name: chatModel.name)
        }
    }
    
    func testModel(model: AIModel) async -> Bool {
        let service = type.getService()
        let result = await service.testModel(provider: self, model: model)
        return result
    }
}
