//
//  LabelledPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/12/2023.
//

import SwiftUI

struct LabeledPicker<PickerView: View>: View {
    let title: String
    var width: CGFloat = 200 // Default value provided
    let picker: PickerView
    
    var body: some View {
        HStack {
            Text(title)
                .fixedSize()
            Spacer()
            picker
                .labelsHidden()
                .frame(width: width)
        }
    }
}
