//
//  ToolbarItems.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ToolbarItems: ToolbarContent {
    @ObservedObject var session: DialogueSession
    @Binding var isShowSettingsView: Bool
    @Binding var isShowDeleteWarning: Bool
    
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
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    isShowSettingsView.toggle()
                } label: {
                    Text("Chat Settings")
                    Image(systemName: "slider.vertical.3")
                }

                Button {
                    session.resetContext()
                } label: {
                    Text("Reset Context")
                    Image(systemName: "eraser")
                }

                Section {
                    Button(role: .destructive) {
                        isShowDeleteWarning.toggle()
                    } label: {
                        Text("Delete All Messages")
                        Image(systemName: "trash")
                    }
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
                ForEach(Provider.allCases, id: \.self) { provider in
                    Text(provider.name)
                        .tag(provider.id)
                }
            }

            Slider(value: $session.configuration.temperature, in: 0 ... 1, step: 0.1) {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1")
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
                    isShowDeleteWarning.toggle()
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
