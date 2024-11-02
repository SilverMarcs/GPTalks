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
    var chatModel: ChatModel
    @Relationship(deleteRule: .cascade)
    var quickChatModel: ChatModel
    @Relationship(deleteRule: .cascade)
    var titleModel: ChatModel
    @Relationship(deleteRule: .cascade)
    var chatModels: [ChatModel] = []
    
    @Relationship(deleteRule: .cascade)
    var imageModel: ImageModel
    @Relationship(deleteRule: .cascade)
    var toolImageModel: ImageModel
    @Relationship(deleteRule: .cascade)
    var imageModels: [ImageModel] = []
    
    @Relationship(deleteRule: .cascade)
    var sttModel: STTModel
    @Relationship(deleteRule: .cascade)
    var sttModels: [STTModel] = []

    public init(id: UUID = UUID(),
                date: Date = Date(),
                name: String,
                host: String,
                apiKey: String,
                type: ProviderType,
                scheme: HTTPScheme,
                color: String,
                isEnabled: Bool,
                chatModel: ChatModel,
                quickChatModel: ChatModel,
                titleModel: ChatModel,
                imageModel: ImageModel,
                toolImageModel: ImageModel,
                chatModels: [ChatModel] = [],
                imageModels: [ImageModel] = [],
                sttModel: STTModel,
                sttModels: [STTModel] = []) {
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
        let demoImageModel = ImageModel.dalle
        let demoTTSModel = STTModel.whisper
        
        let chatModels = type.getDefaultModels()
        let imageModels = type == .openai ? ImageModel.getOpenImageModels() : []
        let ttsModels = type == .openai ? STTModel.getOpenAITTSModels() : []
        
        
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
            sttModel: ttsModels.first ?? demoTTSModel,
            sttModels: ttsModels
        )
        
        
//        Task {
//            let newModels = await type.getService().refreshModels(provider: provider).map { model in
//                ChatModel(code: model.code, name: model.name)
//            }
//            provider.chatModels.append(contentsOf: newModels)
//        }
        
        return provider
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
            !chatModels.contains(where: { $0.code == model.code })
        }
        
        return newModels.map { chatModel in
            GenericModel(code: chatModel.code, name: chatModel.name)
        }
    }
    
    func testModel(model: any ModelType) async -> Bool {
        let service = type.getService()
        let result = await service.testModel(provider: self, model: model)
        return result
    }
}
