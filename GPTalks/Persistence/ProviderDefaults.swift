//
//  ProviderDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import SwiftUI
import SwiftData

@Model
class ProviderDefaults {
    var defaultProvider: Provider
    var quickProvider: Provider
    var imageProvider: Provider
    var toolImageProvider: Provider
    var toolSTTProvider: Provider

    init(defaultProvider: Provider, quickProvider: Provider, imageProvider: Provider, toolImageProvider: Provider, toolSTTProvider: Provider) {
        self.defaultProvider = defaultProvider
        self.quickProvider = quickProvider
        self.imageProvider = imageProvider
        self.toolImageProvider = toolImageProvider
        self.toolSTTProvider = toolSTTProvider
    }
}
