//
//  TopPSlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct TopPSlider: View {
    @Binding var topP: Double?
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $topP,
                      steps: 0.1,
                      min: 0,
                      max: 1,
                      label: "Top P",
                      defaultValue: 1.0)
    }
}