//
//  TranscriptionCreator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import SwiftUI

struct TranscriptionCreator: View {
    var transSession = TranscriptionSession()
    @State private var showingFilePicker = false
    
    var body: some View {
        Text(transSession.input.absoluteString)
        
        Button("send") {
            Task {
                await transSession.send()
            }
        }
        
        Button("add") {
//
            showingFilePicker.toggle()
        }
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.audio], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                let url = urls[0]
                transSession.input = url
                print("Selected file URL: \(url)")
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
        
        ForEach(transSession.generations) { generation in
            Text(generation.transcription)
        }
    }
}

#Preview {
    TranscriptionCreator()
}
