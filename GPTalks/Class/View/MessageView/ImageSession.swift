//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import OpenAI
import SwiftUI

struct ImageSession: View {
    @State var imageUrl: String = ""
    @State var images: [ImagesResult.URLResult] = []
    @State var txt: String = ""
    @State var model: String = "realistic_vision_v5"
    @State var number: Int = 2

    @State var errorMsg: String = ""
    @State var feedback: String = ""

    @FocusState var isFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            List {
                VStack {
                    ForEach(images, id: \.self) { image in
                        AsyncImage(url: URL(string: image.url!)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .onAppear {
                            feedback = ""
                        }
                    }
                    
                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .onAppear {
                                feedback = ""
                            }
                            .foregroundStyle(.red)
                            .listRowSeparator(.hidden)
                    }
                    
                    if !feedback.isEmpty {
                        Text(feedback)
                            .listRowSeparator(.hidden)
                    }
                    
                    Spacer()
                        .id("bottomID")
                }
                
                .listRowSeparator(.hidden)
            }
            .onChange(of: images.count) {
                scrollToBottom(proxy: proxy, animated: false)
            }
            .background(.background)
#if os(macOS)
            .navigationTitle("Image Generations")
#endif
            .listStyle(.plain)
            .toolbar {
                TextField("Model", text: $model)
#if os(iOS)
                    .textInputAutocapitalization(.never)
#endif
                    .frame(width: 150)
                
                Picker("Number", selection: $number) {
                    ForEach(1 ... 5, id: \.self) { number in
                        Text("Count: \(number)")
                            .tag(number)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                textBox
                    .padding(15)
                    .background(.bar)
            }
        }
    }

    var textBox: some View {
        HStack(spacing: 10) {
            Button {
                images = []
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            
            TextField("Prompt", text: $txt, axis: .vertical)
                .lineLimit(2)
                .focused($isFocused)
            
            Button {
                Task {
                    isFocused = false
                    await send()
                }
            } label: {
                Image(systemName: "paperplane.fill")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!feedback.isEmpty || txt.isEmpty)
        }
    }

    func send() async {
        errorMsg = ""
        feedback = "Generating Images..."
        
        let openAIconfig = AppConfiguration.shared.preferredChatService.config

        let service: OpenAI = OpenAI(configuration: openAIconfig)

        let query2 = ImagesQuery(prompt: txt, model: model, n: Int(number), size: "1024x1024", quality: "standard")

        do {
            let results = try await service.images(query: query2)
            images.append(contentsOf: results.data)

            print(results)
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
