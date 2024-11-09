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
    
    var isPersistent: Bool = false  // added by the app by default and are not deletable
    var extraInfo: String = "" // TODO: add more info about the provider
    var color: String = "#00947A"
    var isEnabled: Bool = true
    
    var type: ProviderType
    var scheme: HTTPScheme
    
    var chatModels: [AIModel] { models.filter { $0.type == .chat } }
    var imageModels: [AIModel] { models.filter { $0.type == .image } }
    var sttModels: [AIModel] { models.filter { $0.type == .stt } }
    
    @Relationship(deleteRule: .cascade)
    var models: [AIModel]
    
    @Relationship(deleteRule: .nullify)
    var chatModel: AIModel
    @Relationship(deleteRule: .nullify)
    var liteModel: AIModel
    
    @Relationship(deleteRule: .nullify)
    var imageModel: AIModel
    
    @Relationship(deleteRule: .nullify)
    var sttModel: AIModel

    public init(id: UUID = UUID(),
                date: Date = Date(),
                name: String,
                host: String,
                apiKey: String,
                type: ProviderType,
                scheme: HTTPScheme,
                color: String,
                isEnabled: Bool,
                models: [AIModel] = [],
                chatModel: AIModel,
                liteModel: AIModel,
                imageModel: AIModel,
                sttModel: AIModel) {
        self.id = id
        self.date = date
        self.name = name
        self.host = host
        self.apiKey = apiKey
        self.type = type
        self.scheme = scheme
        self.color = color
        self.isEnabled = isEnabled
        self.models = models
        self.chatModel = chatModel
        self.liteModel = liteModel
        self.imageModel = imageModel
        self.sttModel = sttModel
    }
    
    
    static func factory(type: ProviderType) -> Provider {
        let allModels = type.getDefaultModels()
        
        let chatModel = allModels.first { $0.type == .chat }
        let imageModel = allModels.first { $0.type == .image }
        let sttModel = allModels.first { $0.type == .stt }
        
        let provider = Provider(
            name: type.name,
            host: type.defaultHost,
            apiKey: "",
            type: type,
            scheme: type.scheme,
            color: type.defaultColor,
            isEnabled: true,
            models: allModels,
            chatModel: chatModel!,
            liteModel: chatModel!,
            imageModel: imageModel ?? AIModel.dalle,
            sttModel: sttModel ?? AIModel.whisper
        )
        
        return provider
    }
}
    
//    func addModel(_ model: GenericModel) {
//        switch model.selectedModelType {
//        case .chat:
//            chatModels.append(AIModel(code: model.code, name: model.name, type: .chat))
//        case .image:
//            imageModels.append(AIModel(code: model.code, name: model.name, type: .image))
//        case .stt:
//            sttModels.append(AIModel(code: model.code, name: model.name, type: .stt))
//        }
//    }
//}

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
