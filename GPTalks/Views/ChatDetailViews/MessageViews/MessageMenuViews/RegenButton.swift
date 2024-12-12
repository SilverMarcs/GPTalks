//
//  RegenButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI
import SwiftData

struct RegenButton: View {
    var group: MessageGroup
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]

    var body: some View {
//        Button {
        #if os(macOS)
            Menu {
                ForEach(providers) { provider in
                    Menu {
                        ForEach(provider.chatModels.filter { $0.isEnabled }) { model in
                            Button(model.name) {
                                group.chat?.config.provider = provider
                                group.chat?.config.model = model
                                Task {
                                    await group.chat?.regenerate(message: group)
                                }
                            }
                        }
                    } label: {
                        Label(provider.name, image: provider.type.imageName)
                    } primaryAction: {
                        group.chat?.config.provider = provider
                        group.chat?.config.model = provider.chatModel
                        Task {
                            await group.chat?.regenerate(message: group)
                        }
                    }
                }
            } label: {
                Label("Regenerate", systemImage: "arrow.2.circlepath")
            } primaryAction: {
                Task {
                    await group.chat?.regenerate(message: group)
                }
            }
        #else
        Button {
            Task {
                await group.chat?.regenerate(message: group)
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
        #endif
    }
}
