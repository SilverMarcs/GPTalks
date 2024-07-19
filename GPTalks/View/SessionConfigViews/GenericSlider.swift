//
//  TemperatureSlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct GenericSlider: View {
    @Binding var value: Double
    var steps: Double
    var min: Double
    var max: Double
    var label: String
    
    var body: some View {
        Slider(value: $value, in: min ... max, step: steps) {
            Text(label)
        } minimumValueLabel: {
            Text(String(Int(min)))
        } maximumValueLabel: {
            Text(String(Int(max)))
        }
    }
}

struct TemperatureSlider: View {
    // default 1
    @Binding var temperature: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $temperature, steps: 0.2, min: 0, max: 2,
                      label: shortLabel ? "Temp" : "Temperature")
    }
}

struct PresencePenaltySlider: View {
    @Binding var penalty: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty, steps: 0.4, min: -2, max: 2,
                      label: shortLabel ? "P-Penalty" : "Presence Penalty")
    }
}

struct FrequencyPenaltySlider: View {
    // default 0
    @Binding var penalty: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty, steps: 0.2, min: 0, max: 2,
                      label: shortLabel ? "F-Penalty" : "Frequency Penalty")
    }
}

struct TopPSlider: View {
    // default 1
    @Binding var topP: Double
    
    var body: some View {
        GenericSlider(value: $topP, steps: 0.1, min: 0, max: 1,
                      label: "Top P")
    }
}


#Preview {
//    GenericSlider(value: .constant(5))
}
