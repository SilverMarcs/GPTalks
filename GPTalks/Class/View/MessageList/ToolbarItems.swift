//
//  ToolbarItems.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ToolbarItems: ToolbarContent {
    @Bindable var session: DialogueSession
    
    @State var isShowSettingsView: Bool = false
    
    var body: some ToolbarContent {
#if os(macOS)
        macOS
        #else
        iOS
        #endif
    }
    
#if os(iOS)
    @ToolbarContentBuilder
    var iOS: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button {
                isShowSettingsView.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text(session.title)
                        .foregroundColor(.primary)
                        .bold()
                    Image(systemName:"chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .foregroundStyle(.primary)
            .sheet(isPresented: $isShowSettingsView) {
                DialogueSettingsView(configuration: $session.configuration, title: $session.title)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {

                Button {
                    session.resetContext()
                } label: {
                    Text("Reset Context")
                    Image(systemName: "eraser")
                }

                Button(role: .destructive) {
//                    isShowDeleteWarning.toggle()
                    session.removeAllConversations()
                } label: {
                    Text("Delete All Messages")
                    Image(systemName: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
#endif
    
    @ToolbarContentBuilder
    var macOS: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                isShowSettingsView = true
            } label: {
                Image(systemName: "square.text.square")
            }
            .popover(isPresented: $isShowSettingsView) {
                VStack {
                    Text("System Prompt")
                    TextEditor(text: $session.configuration.systemPrompt)
                        .font(.body)
                        .frame(width: 230, height: 70)
                        .scrollContentBackground(.hidden)
                }
                .padding(10)
            }
        }

        ToolbarItemGroup {
            Picker("Provider", selection: $session.configuration.provider) {
                ForEach(Provider.availableProviders, id: \.self) { provider in
                    Text(provider.name)
                        .tag(provider.id)
                }
            }

            Slider(value: $session.configuration.temperature, in: 0 ... 2, step: 0.2) {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("2")
            }
            .frame(width: 130)

            Picker("Model", selection: $session.configuration.model) {
                ForEach(session.configuration.provider.models, id: \.self) { model in
                    Text(model.name)
                        .tag(model.id)
                }
            }
            .frame(width: 125)

            Picker("Context", selection: $session.configuration.contextLength) {
                ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                    Text("\(number) Messages")
                        .tag(number)
                }
            }

            Menu {
                Button {
                    session.resetContext()
                } label: {
                    Text("Reset Context")
                    Image(systemName: "eraser")
                }

                Button(role: .destructive) {
//                    isShowDeleteWarning.toggle()
                    session.removeAllConversations()
                } label: {
                    Text("Delete All Messages")
                    Image(systemName: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuIndicator(.hidden)
        }
    }
}
