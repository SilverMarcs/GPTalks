//
//  ProviderGeneral.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderGeneral: View {
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Bindable var provider: Provider
    var reorderProviders: () -> Void
    
    @State var showKey: Bool = false
    @State var showPopover: Bool = false

    @State private var color =
        Color(.sRGB, red: 1, green: 1, blue: 1)

    var body: some View {
        Form {
            Section {
                header
            }
            
            Section("Host Settings") {
                HStack {
                    TextField(provider.type == .vertex ? "Project ID" : "Host URL", text: $provider.host)
                    
                    Button {
                        showPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showPopover) {
                        Text(popoverText)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
                if provider.type == .vertex {
                    GoogleSignIn()
                } else {
                    HStack {
                        if showKey {
                            TextField("API Key", text: $provider.apiKey)
                        } else {
                            SecureField("API Key", text: $provider.apiKey)
                        }
                        
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: !showKey ? "eye.slash" : "eye" )
                                .imageScale(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .truncationMode(.middle)
                    .autocorrectionDisabled(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                #endif
                }
            }
    
            Section("Default Models") {
                ModelPicker(model: $provider.chatModel, models: provider.chatModels, label: "Chat Model")
                
                ModelPicker(model: $provider.titleModel, models: provider.chatModels, label: "Title Model")
            }

            Section("Customisation") {
                HStack {
                    Text("Accent Color")
                    
                    Button {
                        color = Color.getRandomColor()
                    } label: {
                        Image(systemName: "die.face.5")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .rotationEffect(.degrees(45))
                    
                    Spacer()
                    
                    ColorPicker("Accent Color", selection: $color)
                        .labelsHidden()
                }
                .task {
                    color = Color(hex: provider.color)
                }
                .onChange(of: color) {
                    provider.color = color.toHex()
                }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            Toggle("Enabled", isOn: Binding(
                get: { provider.isEnabled },
                set: { newValue in
                    provider.isEnabled = newValue
                    reorderProviders()
                }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
    }
    
    private var header: some View {
        HStack {
            ProviderImage(provider: provider, frame: 33, scale: .large)
            
            Group {
            #if os(macOS)
                TextEditor(text: $provider.name)
            #else
                TextField("Name", text: $provider.name)
            #endif
            }
                .textEditorStyle(.plain)
            #if os(macOS)
                .font(.title)
            #else
                .font(.title2)
            #endif
                .padding(5)
                .onChange(of: provider.name) {
                    provider.name = String(provider.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(18))
                }
            
            Spacer()
            
            defaultSetter
        }
    }
    
    private var defaultSetter: some View {
        Group {
            if provider.id.uuidString == providerManager.defaultProvider {
                Text("DEFAULT")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
            } else {
                Button {
                    providerManager.defaultProvider = provider.id.uuidString
                } label: {
                    Text("Set as Default")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
        }
    }
    
    private var popoverText: String {
        switch provider.type {
        case .vertex:
            "Put in your Google Cloud Project ID.\nOnly Anthropic models are supported.\nMake sure to enable Vertex AI Api in GCloud Console and enable Anthropic models."
        case .openai, .google, .anthropic, .local:
            "Omit https:// and /v1/ from the URL.\nFor example: api.openai.com"
        }
    }
}

#Preview {
    return ProviderGeneral(provider: .openAIProvider) {}
        .padding()
        .frame(width: 500, height: 600)
}
