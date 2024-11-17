//
//  BoolControlledLabelStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct BoolControlledLabelStyle: LabelStyle {
    var showTitle: Bool     // << default one !!
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if showTitle {
                configuration.title
                configuration.icon
            } else {
                configuration.icon
            }
        }
    }
}
