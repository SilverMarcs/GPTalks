//
//  ModelRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ModelRow: View {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Bindable var model: AIModel
    var reorderModels: () -> Void
    
    @State private var isTestingModel = false
    @State private var testResult: Bool? = nil
    
    var body: some View {
        Group {
            #if os(macOS) || targetEnvironment(macCatalyst)
            HStack(spacing: 0) {
                Toggle("Enabled", isOn: $model.isEnabled)
                    .frame(maxWidth: 39, alignment: .leading)

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
        .opacity(model.isEnabled ? 1 : 0.5)
        .onChange(of: model.isEnabled) {
            reorderModels()
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
                #if os(macOS) || targetEnvironment(macCatalyst)
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
                .foregroundColor(model.lastTestResult == nil ? .primary : model.lastTestResult! ? .green : .red)
            }
        }
    }
    
    func runModelTest() async {
        isTestingModel = true
        testResult = await testModel()
        isTestingModel = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            testResult = nil
        }
    }
    
    func testModel() async -> Bool {
        if let provider = model.provider {
            let service = provider.type.getService()
            let result = await service.testModel(provider: provider, model: model)
            model.lastTestResult = result
            return result
        }
        return false
    }
}

#Preview {
    let model = AIModel(code: "gpt-3.5-turbo", name: "GPT-3.5 Turbo")
    
    ModelRow(model: model) {}
}
