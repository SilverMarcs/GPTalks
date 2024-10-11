//
//  ImageContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI
import SwiftData

struct ImageContentView: View {
    @Environment(ImageSessionVM.self) private var sessionVM
    @State var showingInspector: Bool = true
    
    var body: some View {
        NavigationSplitView {
            ImageSessionList()
        } detail: {
            if let imageSession = sessionVM.activeImageSession {
                ImageGenerationList(session: imageSession)
            } else {
                Text("^[\(sessionVM.imageSelections.count) Image Session](inflect: true) Selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .font(.title)
            }
        }
        #if os(macOS)
        .inspector(isPresented: $showingInspector) {
            if let imageSession = sessionVM.activeImageSession {
                ImageInspector(session: imageSession, showingInspector: $showingInspector)
            } else {
                Image(systemName: "gear")
                    .imageScale(.large)
            }
        }
        #endif
    }
}

#Preview {
    ImageContentView()
}
