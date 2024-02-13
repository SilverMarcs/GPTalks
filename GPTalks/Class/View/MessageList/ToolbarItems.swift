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

    #if !os(macOS)
        @ToolbarContentBuilder
        var iOS: some ToolbarContent {
            #if !os(visionOS)
            ToolbarItem(placement: .principal) {
                HStack {
                    Button {
                        isShowSettingsView.toggle()
                    } label: {
                        iosNavTitle
                    }
                    .foregroundStyle(.primary)
                    .sheet(isPresented: $isShowSettingsView) {
                        DialogueSettingsView(configuration: $session.configuration, title: $session.title)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.leading, -15)
            }
            #endif
            
                    #if !os(visionOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("\(session.getMessageCountAfterResetMarker())/\(session.configuration.contextLength)")
                            .font(.callout)
                            .opacity(0.8)
                    }
                    #else
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowSettingsView = true
                        } label: {
                            Text("Config")
                        }
                        .sheet(isPresented: $isShowSettingsView) {
                            DialogueSettingsView(configuration: $session.configuration, title: $session.title)
                        }
                    }
                    #endif
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        session.removeAllConversations()
                    } label: {
                        Text("Delete All Messages")
                        Image(systemName: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.button)
              }
        }

        var iosNavTitle: some View {
            HStack {
                ProviderImage(radius: 9, color: session.configuration.provider.accentColor, frame: 30)
                VStack(alignment: .leading, spacing: 1) {
                    Text(session.title)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .bold()
                    HStack(spacing: 3) {
                        Group {
                            Text(session.configuration.model.name)
                            //                            .padding(.horizontal, 5)
                            //                            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 18))
                            //                            .roundedRectangleOverlay()
                            Text("•")

                            Text(session.configuration.systemPrompt)
                                .frame(maxWidth: 140, alignment: .leading)
                           
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        
//                        Image(systemName: "chevron.right")
//                            .font(.system(size: 8))
//                            .foregroundStyle(.secondary)
//                            .padding(.leading, -4)
                    }
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

            Menu {
                Picker("Context Length", selection: $session.configuration.contextLength) {
                    ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                        Text("\(number) Messages")
                            .tag(number)
                    }
                }

                Button("Regenerate") {
                    Task {
                        await session.regenerateLastMessage()
                    }
                }

                Button("Delete All Messages") {
                    session.removeAllConversations()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuIndicator(.hidden)
        }
    }
}
