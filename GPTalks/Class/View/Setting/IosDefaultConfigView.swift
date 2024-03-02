//
//  DefaultConfigView.swift
//  GPTalks
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct IosDefaultConfigView: View {
    var body: some View {
        NavigationView {
            Form {
                Section("Default Settings") {
                    DefaultTempSlider()
                }
                
                Section("System Prompt") {
                    DefaultSystemPrompt()
                        .lineLimit(4, reservesSpace: true)
                }
            }
        }
    }
}
