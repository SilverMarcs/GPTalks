//
//  ModelTester.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/10/2024.
//

import SwiftUI

struct ModelTester: View {
    var provider: Provider
    var model: AIModel
    
    @State var isTesting = false
    
    var body: some View {
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
