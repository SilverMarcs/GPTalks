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
    var defaultValue: String?
    
    @State var showPopover = false
    
    var body: some View {
        Slider(value: $value, in: min ... max, step: steps) {
            HStack {
                Text(label)
                
                Group {
                    if let _ = defaultValue {
                        Button {
                            showPopover.toggle()
                        } label: {
                            Label("Default", systemImage: "info.circle")
                        }
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .popover(isPresented: $showPopover) {
                    HStack {
                        if let defaultValue {
                            Text("Default: " + defaultValue)
                            
                            Button("Reset") {
                                if let double = Double(defaultValue) {
                                    value = double
                                }
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
            }
        } minimumValueLabel: {
            Text(String(Int(min)))
        } maximumValueLabel: {
            Text(String(Int(max)))
        }
    }
}

struct TemperatureSlider: View {
    @Binding var temperature: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $temperature, steps: 0.2, min: 0, max: 2,
                      label: shortLabel ? "Temp" : "Temperature",
                      defaultValue: shortLabel ? nil : "1.0")
    }
}

struct PresencePenaltySlider: View {
    @Binding var penalty: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty, steps: 0.4, min: -2, max: 2,
                      label: shortLabel ? "P-Penalty" : "Presence Penalty",
                      defaultValue: shortLabel ? nil : "0.0")
    }
}

struct FrequencyPenaltySlider: View {
    @Binding var penalty: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $penalty, steps: 0.2, min: 0, max: 2,
                      label: shortLabel ? "F-Penalty" : "Frequency Penalty",
                      defaultValue: shortLabel ? nil : "0.0")
    }
}

struct TopPSlider: View {
    @Binding var topP: Double
    var shortLabel: Bool = false
    
    var body: some View {
        GenericSlider(value: $topP, steps: 0.1, min: 0, max: 1,
                      label: "Top P",
                      defaultValue: shortLabel ? nil : "1.0")
    }
}


//#Preview {
//    GenericSlider(value: .constant(5))
//}
