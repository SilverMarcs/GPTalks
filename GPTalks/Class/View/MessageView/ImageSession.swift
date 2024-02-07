//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/02/2024.
//

import OpenAI
import SwiftUI
import Photos
#if os(iOS)
import VisualEffectView
#endif

struct ImageSession: View {
    @Environment(\.colorScheme) var colorScheme

    @State var imageUrl: String = ""
    @Binding var images: [ImagesResult.URLResult]
    @State var txt: String = ""
    @State var model: String = "realistic_vision_v5"
    @State var number: Int = 2

    @State var errorMsg: String = ""
    @State var feedback: String = ""

    @FocusState var isFocused: Bool

    @State private var isZoomViewPresented = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(images, id: \.self) { image in
                    AsyncImage(url: URL(string: image.url!)) { asyncImage in
                        asyncImage
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .scaledToFit()
                            .onTapGesture {
                                 isZoomViewPresented = true
                             }
                            .contextMenu {
                                Button(action: {
                                    #if os(iOS)
                                    saveImageToPhotos(url: URL(string: image.url!))
                                    #else
                                    saveImageToPicturesFolder(url: URL(string: image.url!))
                                    #endif
                                }) {
                                    Text("Save Image")
                                    Image(systemName: "square.and.arrow.down")
                                }
                            }
                    } placeholder: {
                        ProgressView()
                    }
                    #if os(iOS)
                    .sheet(isPresented: $isZoomViewPresented) {
                        ZoomableImageView(imageUrl: URL(string: image.url!))
                      }
                    #endif
                    .listRowSeparator(.hidden)
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
                    .listRowSeparator(.hidden)
                    .id("bottomID")
            }
            .listStyle(.plain)
            .onTapGesture {
                isFocused = false
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
                        ForEach(1 ... 4, id: \.self) { number in
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
        URLSession.shared.dataTask(with: url) { data, response, error in
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
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                images = []
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
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
    
    private var imageSize: CGFloat {
        #if os(macOS)
            20
        #else
            22
        #endif
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

}

//
//struct ImageDetailView: View {
//    let imageURL: URL
//    @State private var zoomScale: CGFloat = 1.0
//
//    var body: some View {
//        ScrollView([.horizontal, .vertical], showsIndicators: false) {
//            AsyncImage(url: imageURL    ) { asyncImage in
//                asyncImage
//                    .resizable()
//                    .scaledToFit()
//                    .scaleEffect(zoomScale)
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { value in
//                                zoomScale = value
//                            }
//                    )
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}

//struct ZoomableImageView: View {
//    let imageUrl: URL?
//    @State private var scale: CGFloat = 1.0
//    
//    var body: some View {
//        GeometryReader { geometry in
//            AsyncImage(url: imageUrl) { image in
//                image
//                    .resizable()
//                    .scaledToFit()
//                    .scaleEffect(scale)
//                    .frame(width: geometry.size.width, height: geometry.size.height)
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { value in
//                                scale = value.magnitude
//                            }
//                            .onEnded { _ in
//                                withAnimation {
//                                    scale = 1.0
//                                }
//                            }
//                    )
//            } placeholder: {
//                ProgressView()
//            }
//        }
//    }
//}
