//
//  ProviderGeneral.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderGeneral: View {
    @Bindable var provider: Provider
    var reorderProviders: () -> Void
    
    @ObservedObject var providerManager = ProviderManager.shared
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
                    TextField("Host URL", text: $provider.host)
                    
                    Button {
                        showPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showPopover) {
                        Text("Omit https:// and /v1/ from the URL.\nFor example: api.openai.com")
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
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
    
            Section("Default Models") {
                ModelPicker(model: $provider.chatModel, models: provider.chatModels, label: "Chat Model")
                
                ModelPicker(model: $provider.titleModel, models: provider.chatModels, label: "Title Model")
            }

            Section("Customisation") {
                HStack {
                    ColorPicker("Accent Color", selection: $color)
                        .onAppear {
                            color = Color(hex: provider.color)
                        }
                        .onChange(of: color) {
                            provider.color = color.toHex()
                        }

                    Button {
                        color = Color.getRandomColor()
                    } label: {
                        Image(systemName: "die.face.2")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .rotationEffect(.degrees(45))
                }
                    
                Picker("Type", selection: $provider.type) {
                    ForEach(ProviderType.allCases, id: \.self) { type in
                        Text(type.name).tag(type)
                    }
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
            ProviderImage(provider: provider, frame: 33)
            
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
}

#Preview {
    let provider = Provider.factory(type: .openai)

    return ProviderGeneral(provider: provider) {}
        .padding()
        .frame(width: 500, height: 600)
}
