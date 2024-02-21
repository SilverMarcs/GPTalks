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

    var body: some View {
        ScrollViewReader { proxy in
            list
            .navigationTitle("Image Generations")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                imageSession.addDummies()
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
#if !os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
#endif
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        Menu {
                            Picker("Provider", selection: $imageSession.configuration.provider) {
                                ForEach(Provider.availableProviders, id: \.self) { provider in
                                    Text(provider.name)
                                }
                            }
                        } label: {
                            Label("Provider", systemImage: "building.2")
                        }
                        
                        Menu {
                            Picker("Model", selection: $imageSession.configuration.model) {
                                ForEach(imageSession.configuration.provider.imageModels, id: \.self) { model in
                                    Text(model.name)
                                }
                            }
                        } label: {
                            Label("Model", systemImage: "cpu")
                        }
                        
                        Menu {
                            Picker("Number", selection: $imageSession.configuration.count) {
                                ForEach(1 ... 4, id: \.self) { number in
                                    Text("Count: \(number)")
                                        .tag(number)
                                }
                            }
                        } label: {
                            Label("Count", systemImage: "number")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
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

//                if !errorMsg.isEmpty {
//                    Text(errorMsg)
//                        .foregroundStyle(.red)
//                        .listRowSeparator(.hidden)
//                }
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
//                .padding(.horizontal, 12)
            }
            .padding(.horizontal)

//                if !errorMsg.isEmpty {
//                    Text(errorMsg)
//                        .foregroundStyle(.red)
//                }
            
                Spacer()
                .id("bottomID")
                .listRowSeparator(.hidden)
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
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
    }
    
    @ViewBuilder
    private var sendButton: some View {
        let empty = imageSession.input.isEmpty
        
        Button {
            Task { @MainActor in
                await imageSession.send()
            }
        } label: {
            Image(systemName: empty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .disabled(empty)
                .foregroundColor(empty ? .secondary : .accentColor)
            #if os(macOS)
                .frame(width: imageSize + 1, height: imageSize + 1)
            #else
                .background(.white)
                .clipShape(Circle())
                .frame(width: imageSize - 3, height: imageSize - 3)
            #endif
        }
        .keyboardShortcut(.return, modifiers: .command)
        .foregroundColor(.secondary)
        .disabled(empty)
        .fontWeight(.semibold)
        .animation(.interactiveSpring, value: empty)
//        .contentShape(Rectangle())
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
//        Button("hidden") {
//            focused = true
//        }
//        .keyboardShortcut("l", modifiers: .command)
//        .hidden()
    }
    
    private var placeHolderTextColor: Color {
        #if os(macOS)
        Color(.placeholderTextColor)
        #else
        Color(.placeholderText)
        #endif
    }
    
}

