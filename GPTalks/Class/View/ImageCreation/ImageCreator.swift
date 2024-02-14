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

    @State var imageUrl: String = ""
    @Binding var generations: [ImageObject]
    @State var txt: String = ""
    @State var number: Int = 1

    @State var errorMsg: String = ""
    @State var feedback: String = ""

    @FocusState var isFocused: Bool

    @State private var isZoomViewPresented = false
    
    @State var previewUrl = ""
    
    @State var showWarning = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                    ForEach(generations) { generation in
                        Group {
                            GenerationView(generation: generation)
                            Divider()
                        }
                        .padding(.horizontal, 7)
                    }
                    .listRowSeparator(.hidden)
                    
                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .onAppear {
                                feedback = ""
                            }
                            .foregroundStyle(.red)
                            .listRowSeparator(.hidden)
                    }

                    Spacer()
                        .listRowSeparator(.hidden)
                        .id("bottomID")
//                }
            
            }
//            .onAppear {
//                showWarning = true
//            }
//            .alert("Images are not preserved on app close", isPresented: $showWarning) {
//                Button("Ok") {
//                    showWarning = false
//                    isFocused = true
//                }
//            }
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
//            .listStyle(.plain)
            .onTapGesture {
                isFocused = false
            }
            .onChange(of: generations.count) {
                feedback = ""
                scrollToBottom(proxy: proxy, animated: false)
            }
            .background(.background)
            #if os(macOS)
            .navigationTitle("Image Generations")
            .navigationSubtitle("subtitle")
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
    
    func saveImage(url: URL) {
        #if os(iOS)
            saveImageToPhotos(url: url)
        #elseif os(macOS)
            saveImageToPicturesFolder(url: url)
        #else
            print("Not supported.")
        #endif
    }

    #if os(iOS)
        private func saveImageToPhotos(url: URL?) {
            guard let url = url else { return }

            // Request permission to save to the photo library
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Download the image data
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        guard let data = data, let image = UIImage(data: data), error == nil else { return }

                        // Save the image to the photo library
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        }) { success, error in
                            if let error = error {
                                print("Error saving image to Photos: \(error)")
                            } else if success {
                                print("Image successfully saved to Photos")
                            }
                        }
                    }.resume()
                } else {
                    print("Permission to access the photo library was denied.")
                }
            }
        }
    #endif
    
    #if os(macOS)
        private func saveImageToPicturesFolder(url: URL?) {
            guard let url = url else { return }
        
            // Download the image data
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = NSImage(data: data), error == nil else { return }
            
                // Get the user's Pictures folder URL
                if let picturesFolderURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first {
                    let saveURL = picturesFolderURL.appendingPathComponent(url.lastPathComponent)
                
                    // Save the image to the Pictures folder
                    if let tiffData = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffData) {
                        let imageData = bitmapImage.representation(using: .png, properties: [:]) // You can choose .jpeg or other formats
                        do {
                            try imageData?.write(to: saveURL)
                            print("Image successfully saved to Pictures folder")
                        } catch {
                            print("Error saving image: \(error)")
                        }
                    }
                }
            }.resume()
        }
    
        private func saveImage(url: URL?) {
            guard let url = url else { return }
        
            // Download the image data
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = NSImage(data: data), error == nil else { return }
            
                DispatchQueue.main.async {
                    // Present the save panel to the user
                    let savePanel = NSSavePanel()
                    savePanel.allowedContentTypes = [.image] // You can add more file types
                    savePanel.canCreateDirectories = true
                    savePanel.nameFieldStringValue = url.deletingPathExtension().lastPathComponent + ".png"
                
                    if savePanel.runModal() == .OK, let saveURL = savePanel.url {
                        // Save the image to the selected location
                        if let tiffData = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffData) {
                            let imageData = bitmapImage.representation(using: .png, properties: [:])
                            do {
                                try imageData?.write(to: saveURL)
                                print("Image successfully saved to \(saveURL.path)")
                            } catch {
                                print("Error saving image: \(error)")
                            }
                        }
                    }
                }
            }.resume()
        }
    #endif

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
                    if txt.isEmpty {
                        Text("Prompt")
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
            #else
                TextField("Prompt", text: $txt, axis: .vertical)
                    .padding(6)
                    .padding(.horizontal, 4)
                    .frame(minHeight: 33)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1 ... 4)
                    .focused($isFocused)
                    .roundedRectangleOverlay()
            #endif

            Button {
                Task {
                    isFocused = false
                    await send()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(.accentColor)
            }
//            .contentShape(Rectangle())
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!feedback.isEmpty || txt.isEmpty)
        }
    }

    func send() async {
        errorMsg = ""
        feedback = "Generating Images..."

        var streamingTask: Task<Void, Error>?
        let openAIconfig = AppConfiguration.shared.preferredImageService.config
        let service = OpenAI(configuration: openAIconfig)
        let query2 = ImagesQuery(prompt: txt, model: configuration.defaultImageModel, n: Int(number), size: "1024x1024", quality: "standard")

        #if os(iOS)
            streamingTask = Task {
                let application = await UIApplication.shared
                let taskId = await application.beginBackgroundTask {
                    // Handle expiration of background task here
                }

                // Start your network request here
                let results = try await service.generations(query: query2)
                generations.append(contentsOf: results.data)
                print(results)

                // End the background task once the network request is finished
                await application.endBackgroundTask(taskId)
            }

        #else
            streamingTask = Task {
//                let results = try await service.images(query: query2)
//                generations.append(ImageObject(prompt: txt, urls: results.data))
                // Step 1: Create an ImageObject with the prompt and empty URLs.
                let tempImageObject = ImageObject(isGenerating: true, prompt: txt, urls: [])

                // Add this temporary object to your collection.
                generations.append(tempImageObject)

                // Step 2: Perform the asynchronous operation to fetch URLs.
                let results = try await service.images(query: query2)

                // Step 3: Find the ImageObject in your collection and update it with the URLs.
                if let index = generations.firstIndex(where: { $0.id == tempImageObject.id }) {
                    generations[index].urls = results.data
                    generations[index].isGenerating = false
                }
//                print(results)
            }
        #endif

        do {
            try await streamingTask?.value
        } catch {
            errorMsg = error.localizedDescription
        }
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
            20
        #else
            22
        #endif
    }
    
//    private var horizontalPadding: CGFloat {
//        #if os(iOS)
//            50
//        #else
//            85
//        #endif
//    }
}

struct ZoomableImageView: View {
    let imageUrl: URL?
    @State private var zoomScale: CGFloat = 1.0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoomScale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    zoomScale = value
                                    if zoomScale < 1.0 {
                                        zoomScale = 1.0
                                    }
                                }
                        )
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    dismiss()
                                }
                            }
                        }
                        .onTapGesture(count: 2) {
                            withAnimation {
                                zoomScale = 1.0
                            }
                        }
                } placeholder: {
                    ProgressView()
                }
            }
            .background(.black)
        }
    }
}
