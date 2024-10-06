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
    var order: Int = 0
    
    var name: String = ""
    var host: String = ""
    @Attribute(.allowsCloudEncryption)
    var apiKey: String = ""
    
    var type: ProviderType
    var isPersistent: Bool = false  // added by the app by default and are not deletable
    var extraInfo: String = ""
    
    var color: String = "#00947A"
    var isEnabled: Bool = true
    var supportsImage: Bool = false
    
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
    var ttsModel: TTSModel
    @Relationship(deleteRule: .cascade)
    var ttsModels: [TTSModel] = []

    public init(id: UUID = UUID(),
                date: Date = Date(),
                order: Int = 0,
                name: String,
                host: String,
                apiKey: String,
                type: ProviderType,
                color: String,
                isEnabled: Bool,
                supportsImage: Bool,
                chatModel: ChatModel,
                quickChatModel: ChatModel,
                titleModel: ChatModel,
                imageModel: ImageModel,
                toolImageModel: ImageModel,
                chatModels: [ChatModel] = [],
                imageModels: [ImageModel] = [],
                ttsModel: TTSModel,
                ttsModels: [TTSModel] = []) {
        self.id = id
        self.date = date
        self.order = order
        self.name = name
        self.host = host
        self.apiKey = apiKey
        self.type = type
        self.color = color
        self.isEnabled = isEnabled
        self.supportsImage = supportsImage
        self.chatModel = chatModel
        self.quickChatModel = quickChatModel
        self.titleModel = titleModel
        self.imageModel = imageModel
        self.toolImageModel = toolImageModel
        self.chatModels = chatModels
        self.imageModels = imageModels
        self.ttsModel = ttsModel
        self.ttsModels = ttsModels
    }
    
    
    static func factory(type: ProviderType, isDummy: Bool = false) -> Provider {
        let demoImageModel = ImageModel.dalle
        let demoTTSModel = TTSModel.whisper
        
        let chatModels = type.getDefaultModels()
        let imageModels = type == .openai ? ImageModel.getOpenImageModels() : []
        let ttsModels = type == .openai ? TTSModel.getOpenAITTSModels() : []
        
        let provider = Provider(
            name: type.name,
            host: type.defaultHost,
            apiKey: "",
            type: type,
            color: type.defaultColor,
            isEnabled: !isDummy,
            supportsImage: type == .openai,
            chatModel: chatModels.first!,
            quickChatModel: chatModels.first!,
            titleModel: chatModels.first!,
            imageModel: imageModels.first ?? demoImageModel,
            toolImageModel: imageModels.first ?? demoImageModel,
            chatModels: chatModels,
            imageModels: imageModels,
            ttsModel: ttsModels.first ?? demoTTSModel,
            ttsModels: ttsModels
        )
        
        return provider
    }
}

extension Provider {
    func refreshModels() async -> [GenericModel] {
        let refreshedChatModels: [ChatModel] = await type.getService().refreshModels(provider: self)
        let newModels = refreshedChatModels.filter { model in
            !chatModels.contains(where: { $0.code == model.code })
        }
        
        return newModels.map { chatModel in
            GenericModel(code: chatModel.code, name: chatModel.name)
        }
    }
    
    func testModel(model: ChatModel) async -> Bool {
        let service = type.getService()
        let result = await service.testModel(provider: self, model: model)
        return result
    }
}
