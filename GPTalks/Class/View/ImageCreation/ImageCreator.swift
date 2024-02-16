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
    @ObservedObject var configuration: AppConfiguration = .shared

    @Binding var generations: [ImageObject]
    @State var prompt: String = ""
    @State var number: Int = 1

    @State var errorMsg: String = ""
    @FocusState var isTextFieldFocused: Bool
    @State var showWarning = false
    @State var shouldScroll = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                VStack {
                    ForEach(generations) { generation in
                        GenerationView(generation: generation, shouldScroll: $shouldScroll)
                            .padding(.horizontal, 7)

                        Spacer()
                            .frame(height: 30)
                    }
                    .listRowSeparator(.hidden)

                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .foregroundStyle(.red)
                            .listRowSeparator(.hidden)
                    }
                }
                .id("bottomID")
            }
            .onChange(of: shouldScroll) {
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onAppear {
                isTextFieldFocused = true
//                generations.append(ImageObject(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//                generations.append(ImageObject(isGenerating: false, prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//                generations.append(ImageObject(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//                generations.append(ImageObject(isGenerating: true, prompt: "batman v superman", imageModel: "dall-e-3", urls: []))
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                textBox
                    .padding(15)
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
            .onTapGesture {
                isTextFieldFocused = false
            }
            .onChange(of: generations.count) {
                scrollToBottom(proxy: proxy, animated: true)
            }
            .background(.background)
            #if os(macOS)
                .navigationTitle("Image Generations")
//                .navigationSubtitle("subtitle")
            #endif
                .listStyle(.plain)
                .toolbar {
                    TextField("Model", text: $configuration.defaultImageModel)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                        .frame(width: 150)

                    Picker("Number", selection: $number) {
                        ForEach(1 ... 4, id: \.self) { number in
                            Text("Count: \(number)")
                                .tag(number)
                        }
                    }
                }
        }
    }

    var textBox: some View {
        HStack(spacing: 10) {
            Button {
                generations = []
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }
            .buttonStyle(.plain)

            #if os(macOS)
                ZStack(alignment: .leading) {
                    if prompt.isEmpty {
                        Text("Prompt")
                            .font(.body)
                            .padding(6)
                            .padding(.leading, 4)
                            .foregroundColor(Color(.placeholderTextColor))
                    }
                    TextEditor(text: $prompt)
                        .font(.body)
                        .frame(maxHeight: 400)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(6)
                        .scrollContentBackground(.hidden)
                        .roundedRectangleOverlay()
                }
            #else
                TextField("Prompt", text: $prompt, axis: .vertical)
                    .padding(6)
                    .padding(.horizontal, 4)
                    .frame(minHeight: 33)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1 ... 4)
                    .focused($isTextFieldFocused)
                    .roundedRectangleOverlay()
            #endif

            Button {
                Task {
                    isTextFieldFocused = false
                    await send()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(prompt.isEmpty)
        }
    }

    func send() async {
        errorMsg = ""

        var streamingTask: Task<Void, Error>?
//        let openAIconfig = AppConfiguration.shared.preferredImageService.config
//        let service = OpenAI(configuration: openAIconfig)
        let query = ImagesQuery(prompt: prompt, model: configuration.defaultImageModel, n: Int(number), size: "1024x1024", quality: "standard")

        #if os(iOS)
            streamingTask = Task {
                let application = UIApplication.shared
                let taskId = application.beginBackgroundTask {
                    // Handle expiration of background task here
                }

                // Start your network request here
//                let results = try await service.generations(query: query2)
//                generations.append(contentsOf: results.data)
//                print(results)
                try await sendHelper(query: query)

                // End the background task once the network request is finished
                application.endBackgroundTask(taskId)
            }

        #else
            streamingTask = Task {
//                let results = try await service.images(query: query2)
//                generations.append(ImageObject(prompt: txt, urls: results.data))

                try await sendHelper(query: query)
            }
        #endif

        do {
            try await streamingTask?.value
        } catch {
            errorMsg = error.localizedDescription
        }
    }
    
    func sendHelper(query: ImagesQuery) async throws {
        let openAIconfig = AppConfiguration.shared.preferredImageService.config
        let service = OpenAI(configuration: openAIconfig)
        // Step 1: Create an ImageObject with the prompt and empty URLs.
        let tempImageObject = ImageObject(isGenerating: true, prompt: prompt, imageModel: configuration.defaultImageModel, urls: [])

        // Add this temporary object to your collection.
        generations.append(tempImageObject)

        // Step 2: Perform the asynchronous operation to fetch URLs.
        let results = try await service.images(query: query)

        // Step 3: Find the ImageObject in your collection and update it with the URLs.
        if let index = generations.firstIndex(where: { $0.id == tempImageObject.id }) {
            let urlObjects = results.data.compactMap { urlResult -> URL? in
                guard let urlString = urlResult.url, let url = URL(string: urlString) else {
                    return nil
                }
                return url
            }
            generations[index].urls = urlObjects
            generations[index].isGenerating = false
        }
        print(results)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
            20
        #else
            22
        #endif
    }
}
