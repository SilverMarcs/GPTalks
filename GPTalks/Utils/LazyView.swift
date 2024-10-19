//
//  LazyView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/10/2024.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
