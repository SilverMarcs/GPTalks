//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ChatModelRow: View {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Binding var model: ChatModel
    var provider: Provider
    
    @State private var isTestingModel = false
    @State private var testResult: Bool? = nil
    
    var body: some View {
        Group {
            #if os(macOS)
            HStack(spacing: 0) {
                // TODO: use grid
                TextField("Code", text: $model.code)
                    .frame(maxWidth: 300, alignment: .leading)
                
                TextField("Name", text: $model.name)
                    .frame(maxWidth: 205, alignment: .leading)

                modelTester
                    .frame(maxWidth: 35, alignment: .center)
            }
            #else
            if editMode?.wrappedValue == .active {
                VStack(alignment: .leading) {
                    Text(model.name)
                    Text(model.code)
                }
            } else {
                DisclosureGroup {
                    TextField("Code", text: $model.code)
                    
                    TextField("Name", text: $model.name)
                } label: {
                    HStack {
                        Text(model.name)
                        Spacer()
                        modelTester
                    }
                }
            }
            #endif
        }
        #if !os(macOS)
        .swipeActions(edge: .leading) {
            Button {
                model.isEnabled.toggle()
            } label: {
                Image(systemName: model.isEnabled ? "xmark" : "checkmark")
            }
            .tint(model.isEnabled ? .gray.opacity(0.7) : .accentColor)
            
            Button {
                model.type = model.type == .image ? .chat : .image
            } label: {
                Image(systemName: model.type == .chat ? "photo" : "bubble.left")
            }
            .tint(model.type == .chat ? .pink : .green)
        }
        #endif
    }
    
    var modelTester: some View {
        HStack {
            if isTestingModel {
                ProgressView()
                #if os(macOS)
                    .controlSize(.small)
                #endif
            } else if let result = testResult {
                Image(systemName: result ? "checkmark.circle" : "xmark.circle")
                    .foregroundStyle(result ? .green : .red)
            } else {
                Button {
                    Task { await runModelTest() }
                } label: {
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func runModelTest() async {
        isTestingModel = true
        testResult = await provider.testModel(model: model)
        isTestingModel = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            testResult = nil
        }
    }
}

#Preview {    
    ChatModelRow(model: Binding.constant(ChatModel.gpt4), provider: .openAIProvider)
}
