//
//  TemperatureSlider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct GenericSlider: View {
    @Binding var value: Double?
    var steps: Double
    var min: Double
    var max: Double
    var label: String
    var defaultValue: Double
    
    @State private var showPopover = false
    
    var body: some View {
        if let bindingValue = value {
            Slider(value: Binding( get: { bindingValue }, set: { self.value = $0 }),
                   in: min...max,
                   step: steps) {
                HStack {
                    Text(label)
                    
                    Button {
                        showPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .popover(isPresented: $showPopover) {
                        HStack {
                            Button("Default") {
                                self.value = defaultValue
                            }
                            
                            Button( role: .destructive) {
                                self.value = nil
                            } label: {
                                Text("Unset")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(10)
                    }
                }
            } minimumValueLabel: {
                Text("")
                    .frame(width: 0)
            } maximumValueLabel: {
                Text(String(format: "%.1f", bindingValue))
                    .frame(width: 20)
            }
        } else {
            HStack {
                Text(label)
                Spacer()
                Button("Set") {
                    self.value = defaultValue
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
            }
        }
    }
}
