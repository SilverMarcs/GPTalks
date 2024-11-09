//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/10/2024.
//

import SwiftUI

struct ModelRow: View {
    var provider: Provider
    @Binding var model: AIModel
    
    @State private var isTesting = false
    
    var body: some View {
        HStack {
            #if os(macOS)
            HStack {
                TextField("Name", text: $model.name)
                    .bold()
                TextField("Code", text: $model.code)
                    .monospaced()
            }
            #else
            VStack {
                TextField("Name", text: $model.name)
                    .bold()
                TextField("Code", text: $model.code)
                    .monospaced()
            }
            #endif
            
            Spacer()
            
            if model.type == .chat {
                Button {
                    Task {
                        isTesting = true
                        let result = await provider.testModel(model: model)
                        model.testResult = result
                        isTesting = false
                    }
                } label: {
                    if isTesting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "play.circle")
                            .foregroundStyle(foregroundColor(for: model.testResult))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        #if os(macOS)
        .padding(5)
        #endif
    }
    
    private func foregroundColor(for testResult: Bool?) -> Color {
        switch testResult {
        case .some(true):
            return .green
        case .some(false):
            return .red
        case .none:
            return .primary
        }
    }
}
