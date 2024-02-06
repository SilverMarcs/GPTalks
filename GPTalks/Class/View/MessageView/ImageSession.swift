//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import OpenAI
import SwiftUI
#if os(iOS)
import VisualEffectView
#endif

struct ImageSession: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var imageUrl: String = ""
    @State var images: [ImagesResult.URLResult] = []
    @State var txt: String = ""
    @State var model: String = "realistic_vision_v5"
    @State var number: Int = 2

    @State var errorMsg: String = ""
    @State var feedback: String = ""

    @FocusState var isFocused: Bool
    
//    var streamingTask: Task<Void, Error>?

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
                .onTapGesture {
                    isFocused = false
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
                    #if os(iOS)
                        .background(
                            VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.7, blurRadius: 18, scale: 1)
                                .ignoresSafeArea()
                        )
                    #else
                        .background(.bar)
                    #endif
                    
                }
        }
    }

    var textBox: some View {
        HStack(spacing: 12) {
            Button {
                images = []
            } label: {
                Image(systemName: "trash")
                    .frame(width: 27, height: 27)
            }
            .buttonStyle(.plain)

            #if os(iOS)
                TextField("Prompt", text: $txt, axis: .vertical)
                    .padding(6)
                    .padding(.horizontal, 4)
                    .frame(minHeight: 33)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1 ... 4)
                    .focused($isFocused)
                    .roundedRectangleOverlay()
            #else
            ZStack(alignment: .leading) {
                if txt.isEmpty {
                    Text("Send a message")
                        .font(.body)
                        .padding(6)
                        .padding(.leading, 4)
                        .foregroundColor(Color(.placeholderTextColor))
                }
                TextEditor(text: $txt)
                    .font(.body)
                    .frame(maxHeight: 400)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(6)
                    .scrollContentBackground(.hidden)
                    .roundedRectangleOverlay()
            }
            #endif
            

                Button {
                    Task {
                        isFocused = false
                        await send()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .frame(width: 27, height: 27)
                }
//                .clipShape(Rectangle())
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(!feedback.isEmpty || txt.isEmpty)
            
        }
    }
    
    func send() async {
        errorMsg = ""
        feedback = "Generating Images..."

        var streamingTask: Task<Void, Error>?
        let openAIconfig = AppConfiguration.shared.preferredChatService.config
        let service: OpenAI = OpenAI(configuration: openAIconfig)
        let query2 = ImagesQuery(prompt: txt, model: model, n: Int(number), size: "1024x1024", quality: "standard")

        #if os(iOS)
            streamingTask = Task {
                let application = await UIApplication.shared
                let taskId = await application.beginBackgroundTask {
                    // Handle expiration of background task here
                }

                // Start your network request here
                let results = try await service.images(query: query2)
                images.append(contentsOf: results.data)
                print(results)

                // End the background task once the network request is finished
                await application.endBackgroundTask(taskId)
            }

        #else
            streamingTask = Task {
                let results = try await service.images(query: query2)
                images.append(contentsOf: results.data)
                print(results)
            }
        #endif

        do {
            try await streamingTask?.value
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
