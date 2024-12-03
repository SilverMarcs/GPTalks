//
//  CacheButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2024.
//

import SwiftUI

struct CacheButton: View {
    @Binding var useCache: Bool
    
    var body: some View {
        Button {
            useCache.toggle()
        } label: {
            Label(useCache ? "Uncache" : "Cache", systemImage: useCache ? "cloud.fill" : "cloud")
        }
        .contentTransition(.symbolEffect(.replace.offUp))
    }
}

#Preview {
    CacheButton(useCache: .constant(false))
}
