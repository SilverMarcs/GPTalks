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
        #if os(macOS)
        content
        #else
        HStack {
            labelView
            content
        }
        #endif
    }
    
    @ViewBuilder
    var content: some View {
        if let bindingValue = value {
            Slider(value: Binding( get: { bindingValue }, set: { self.value = $0 }),
                   in: min...max,
                   step: steps) {
                labelView
            } minimumValueLabel: {
                Text("")
                    .frame(width: 0)
            } maximumValueLabel: {
                Text(String(format: "%.1f", bindingValue))
                #if os(macOS)
                    .frame(width: 17)
                #else
                    .frame(width: 25)
                #endif
            }
        } else {
            LabeledContent(label) {
                Button("Set") {
                    self.value = defaultValue
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
            }
        }
    }
    
    @ViewBuilder
    var labelView: some View {
        if let _ = value {
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
                    #if os(macOS)
                    HStack {
                        popoverContent
                    }
                    .padding(10)
                    #else
                    VStack(spacing: 15) {
                        popoverContent
                    }
                    .padding()
                    .presentationCompactAdaptation(.popover)
                    #endif
                }
            }
        }
    }

    @ViewBuilder
    private var popoverContent: some View {
        Button("Default") {
            self.value = defaultValue
        }
        
        Button(role: .destructive) {
            self.value = nil
        } label: {
            Text("Unset")
                .foregroundStyle(.red)
        }
    }
}
