//
//  ImageSessionList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct ImageSessionList: View {
    var body: some View {
        List {
#if !os(macOS)
            cardView
#endif
            VStack {
                Spacer()
                Text("Coming Soon")
                Spacer()
            }
        }
        .searchable(text: .constant("Search"))
        .navigationTitle("Images")
    }
    
#if !os(macOS)
private var cardView: some View {
    Section {
        SessionListCards()
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
    .listSectionSpacing(15)
}
#endif
}

#Preview {
    ImageSessionList()
}
