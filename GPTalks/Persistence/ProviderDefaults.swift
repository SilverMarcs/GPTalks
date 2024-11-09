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
    var sttProvider: Provider

    init(defaultProvider: Provider, quickProvider: Provider, imageProvider: Provider, sttProvider: Provider) {
        self.defaultProvider = defaultProvider
        self.quickProvider = quickProvider
        self.imageProvider = imageProvider
        self.sttProvider = sttProvider
    }
}
