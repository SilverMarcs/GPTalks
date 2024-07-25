//
//  ModelTable.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelTable: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider
    
    @State private var selections: Set<AIModel> = []

    var body: some View {
        Form {
            List(selection: $selections) {
                Section(header:
                    HStack(spacing: 0) {
                        Image(systemName: "photo").frame(width: 20)
                        Text("Code").frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17)
                        Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    }
                ) {
                    ModelCollection(provider: provider)
                }
            }
            #if os(macOS)
            .alternatingRowBackgrounds()
            #endif
            .labelsHidden()
        }
        .formStyle(.grouped)
    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
