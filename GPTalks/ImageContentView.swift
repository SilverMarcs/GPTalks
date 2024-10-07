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
//    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
//    var providers: [Provider]
    
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