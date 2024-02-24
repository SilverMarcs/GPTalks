//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import OpenAI
import Photos
import SwiftUI
#if os(iOS)
    import VisualEffectView
#endif

struct ImageCreator: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Bindable var imageSession: ImageSession
    
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            list
            #if os(macOS)
            .navigationTitle("Image Generations")
            .navigationSubtitle(imageSession.configuration.model == .customImage ? imageSession.configuration.model .id : imageSession.configuration.model .name)
            #else
            .navigationTitle(imageSession.configuration.model == .customImage ? imageSession.configuration.model .id : imageSession.configuration.model .name)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            #endif
//            .onAppear {
//                imageSession.addDummies()
//            }
            .onChange(of: imageSession.generations) {
                withAnimation {
                    scrollToBottom(proxy: proxy)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack(spacing: 12) {
                    clearGenerations
                    
                    inputBox

                    #if os(macOS)
                    sendButton
                    #endif
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, verticalPadding)
                .padding(.bottom, verticalPadding + 2)
                #if os(iOS)
                    .background(
                        VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.7, blurRadius: 18, scale: 1)
                            .ignoresSafeArea()
                    )
                #elseif os(macOS)
                    .background(.bar)
                #elseif os(visionOS)
                    .background(.regularMaterial)
                #endif
            }
            .toolbar {
#if os(macOS)

                providerPicker

                modelPicker
                    .frame(maxWidth: 110)
        
                countPicker
#else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                    
                ToolbarItem {
                    Menu {
                        Menu {
                            providerPicker
                        } label: {
                            Label(imageSession.configuration.provider.name, systemImage: "building.2")
                        }
                        
                        Menu {
                            modelPicker
                        } label: {
                            Label(imageSession.configuration.model.name, systemImage: "cpu")
                        }
                        
                        Menu {
                            countPicker
                        } label: {
                            Label("Count: " + String(imageSession.configuration.count), systemImage: "number")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
#endif
            }
        }
    }
    
    @ViewBuilder
    var list: some View {
        #if os(macOS)
        List {
            VStack {
                ForEach(imageSession.generations) { generation in
                    GenerationView(generation: generation, shouldScroll: Binding.constant(false))
                        .padding(.horizontal, 7)

                    Spacer()
                        .frame(height: 30)
                }
                .listRowSeparator(.hidden)

            }
            .id("bottomID")
        }
        .listStyle(.plain)
        #else
        ScrollView {
            LazyVStack {
                ForEach(imageSession.generations, id: \.self) { generation in
                    GenerationView(generation: generation, shouldScroll: Binding.constant(false))
                        .listRowSeparator(.hidden)
                        .id(generation.id)                    
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
            
                Spacer()
                .id("bottomID")
                .listRowSeparator(.hidden)
            }
        .onTapGesture {
            isFocused = false
        }
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        31
        #endif
    }
    
    @ViewBuilder
    private var clearGenerations: some View {
        Button {
            imageSession.generations = []
        } label: {
            Image(systemName: "eraser")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
            #if os(macOS)
                .padding(5)
                .frame(width: imageSize + 1, height: imageSize + 1)
            #else
                .padding(8)
                .frame(width: imageSize + 3, height: imageSize + 3)
            #endif
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    private var sendButton: some View {
        let empty = imageSession.input.isEmpty
        
        Button {
            Task { @MainActor in
                isFocused = false
                
                await imageSession.send()
            }
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
            #if os(macOS)
                .frame(width: imageSize + 1, height: imageSize + 1)
            #else
                .background(empty ? .clear : .white)
                .clipShape(Circle())
                .frame(width: imageSize - 3, height: imageSize - 3)
            #endif
                .foregroundColor(.accentColor)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .opacity(empty ? 0.5 : 1)
        .fontWeight(.semibold)
    }
    
    @ViewBuilder
    private var inputBox: some View {
        ZStack(alignment: .leading) {
            #if os(macOS)
            textEditor
            #else
            textField
            #endif
        }
        .roundedRectangleOverlay()
    }
    
    private var textField: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField("Send a message", text: $imageSession.input, axis: .vertical)
                .focused($isFocused)
                .multilineTextAlignment(.leading)
                .lineLimit(1 ... 15)
                .padding(6)
                .padding(.horizontal, 5)
                .padding(.trailing, 25) // for avoiding send button
                .frame(minHeight: imageSize + 5)
            #if os(iOS)
                .background(
                    VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                        .cornerRadius(18)
                )
            #endif
            
            Group {
                sendButton
                    .offset(x: -4, y: -4)
            }
            .padding(20) // Increase tappable area
            .padding(-20) // Cancel out visual expansion
            .background(Color.clear)
        }
    }

    @ViewBuilder
    private var textEditor: some View {
        if imageSession.input.isEmpty {
            Text("Generate Images")
                .font(.body)
                .padding(5)
                .padding(.leading, 6)
                .foregroundColor(placeHolderTextColor)
        }
        TextEditor(text: $imageSession.input)
            .font(.body)
            .frame(maxHeight: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .scrollContentBackground(.hidden)
    }
    
    private var placeHolderTextColor: Color {
        #if os(macOS)
        Color(.placeholderTextColor)
        #else
        Color(.placeholderText)
        #endif
    }
    
    
    var modelPicker: some View {
        Picker("Model", selection: $imageSession.configuration.model) {
            ForEach(imageSession.configuration.provider.imageModels, id: \.self) { model in
                Text(imageSession.configuration.model == .customImage ? model.id : model.name)
            }
        }
    }
    
    var providerPicker: some View {
        Picker("Provider", selection: $imageSession.configuration.provider) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
            }
        }
    }
    
    var countPicker: some View {
        Picker("N", selection: $imageSession.configuration.count) {
            ForEach(1 ... 4, id: \.self) { number in
                Text("N: \(number)")
                    .tag(number)
            }
        }
    }
    
    private var verticalPadding: CGFloat {
        #if os(iOS)
        return 7
        #else
        return 13
        #endif
    }
}

