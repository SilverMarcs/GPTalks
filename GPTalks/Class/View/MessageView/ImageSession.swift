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
    @State var number: Int = 3
    
    @State var errorMsg: String = ""
    @State var feedback: String = ""

    var body: some View {
        List {
            if !errorMsg.isEmpty {
                Text(errorMsg)
                    .onAppear {
                        feedback = ""
                    }
                    .padding()
                    .foregroundStyle(.red)
                    .listRowSeparator(.hidden)
            }
            
            if !feedback.isEmpty {
                Text(feedback)
                    .listRowSeparator(.hidden)
                    .padding()
            }
            
            VStack {
                ForEach(images, id: \.self) { image in
                    AsyncImage(url: URL(string: image.url!)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .onAppear {
                        feedback = ""
                    }
                    .frame(width: 800, height: 800)
                    .padding()
                }
            }
            .listRowSeparator(.hidden)
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

    var textBox: some View {
        HStack(spacing: 10) {
            TextField("Prompt", text: $txt)
                .textFieldStyle(.roundedBorder)
            Button {
                Task {
                    await send()
                }
            } label: {
                Image(systemName: "paperplane.fill")
            }
        }
    }

    func send() async {
        errorMsg = ""
        feedback = "Generating Images..."
        
        let openAIconfig = OpenAI.Configuration(
            token: AppConfiguration.shared.Okey,
            host: "app.oxyapi.uk"
        )

        let service: OpenAI = OpenAI(configuration: openAIconfig)

        let query2 = ImagesQuery(prompt: txt, model: model, n: Int(number), size: "1024x1024", quality: "standard")

        do {
            let results = try await service.images(query: query2)
            images = results.data

            print(results)
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}
