//
//  FrequencyPenaltySlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct FrequencyPenaltySlider: View {
    @Binding var penalty: Double?
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty,
                      steps: 0.2,
                      min: 0,
                      max: 2,
                      label: shortLabel ? "F-Penalty" : "Frequency Penalty",
                      defaultValue: 0.0)
    }
}