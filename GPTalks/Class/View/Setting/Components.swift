//
//  Components.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/02/2024.
//

import SwiftUI

struct AutoGenTitleEnabler: View {
    @ObservedObject var configuration: AppConfiguration = .shared
    var isPicker: Bool = false
    
    var body: some View {
        if isPicker {
            Picker("AutoGen Title", selection: $configuration.isAutoGenerateTitle) {
                Text("True").tag(true)
                Text("False").tag(false)
            }
        } else {
            Toggle("AutoGen Title", isOn: $configuration.isAutoGenerateTitle)
        }
    }
}


struct MarkdownEnabler: View {
    @ObservedObject var configuration: AppConfiguration = .shared
    var isPicker: Bool = false
    
    var body: some View {
        if isPicker {
            Picker("Markdown Enabled", selection: $configuration.isMarkdownEnabled) {
                Text("True").tag(true)
                Text("False").tag(false)
            }
        } else {
            Toggle("Markdown Enabled", isOn: $configuration.isMarkdownEnabled)
        }
    }
}

struct PreferredChatProvider: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        Picker("Preferred Chat Provider", selection: $configuration.preferredChatService) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
            }
        }
    }
}

struct PreferredImageProvider: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        Picker("Preferred Image Provider", selection: $configuration.preferredImageService) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
            }
        }
    }
}


struct UseToolsPicker: View {
    @ObservedObject var configuration: AppConfiguration = .shared
    var isPicker: Bool = false
    
    var body: some View {
        if isPicker {
            Picker("Use Tools", selection: $configuration.useTools) {
                Text("True").tag(true)
                Text("False").tag(false)
            }
        } else {
            Toggle("Use Tools", isOn: $configuration.useTools)
        }
    }
}

struct DefaultTempSlider: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        HStack(spacing: 15) {
            Slider(value: $configuration.temperature, in: 0...2, step: 0.1) {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("2")
            }
            Text(String(format: "%.2f", configuration.temperature))
        }
    }
}

struct DefaultSystemPrompt: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        TextField("Enter a system prompt", text: $configuration.systemPrompt, axis: .vertical)
    }
}

struct CustomChatModel: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        TextField("Enter a custom chat model", text: $configuration.customChatModel)
    }
}

struct CustomImageModel: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        TextField("Enter a custom image model", text: $configuration.customImageModel)
    }
}

struct CustomVisionModel: View {
    @ObservedObject var configuration: AppConfiguration = .shared

    var body: some View {
        TextField("Enter a custom vision model", text: $configuration.customVisionModel)
    }
}
