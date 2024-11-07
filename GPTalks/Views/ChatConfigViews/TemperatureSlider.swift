//
//  TemperatureSlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

struct TemperatureSlider: View {
    @Binding var temperature: Double?
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $temperature,
                      steps: 0.1,
                      min: 0,
                      max: 2,
                      label: shortLabel ? "Temp" : "Temperature",
                      defaultValue: 1.0)
    }
}
