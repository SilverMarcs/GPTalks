//
//  ImageContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

#if os(macOS)
import SwiftUI
import SwiftData

struct ImageContentView: View {
    @Environment(ImageVM.self) private var sessionVM
    @State var showingInspector: Bool = true
    
    var body: some View {
        NavigationSplitView {
            ImageList()
        } detail: {
            if let imageSession = sessionVM.activeImageSession {
                ImageDetail(session: imageSession)
                    .id(imageSession.id)
            } else {
                Text("^[\(sessionVM.selections.count) Image Session](inflect: true) Selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .font(.title)
            }
        }
        .inspector(isPresented: $showingInspector) {
            if let imageSession = sessionVM.activeImageSession {
                ImageInspector(session: imageSession, showingInspector: $showingInspector)
            } else {
                Image(systemName: "gear")
                    .imageScale(.large)
            }
        }
    }
}

#Preview {
    ImageContentView()
}
#endif
