//
//  PresencePenaltySlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct PresencePenaltySlider: View {
    @Binding var penalty: Double?
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty,
                      steps: 0.4,
                      min: -2,
                      max: 2,
                      label: shortLabel ? "P-Penalty" : "Presence Penalty",
                      defaultValue: 0.0)
    }
}