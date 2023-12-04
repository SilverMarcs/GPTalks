//
//  PlaceHolderView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/12/2023.
//

import SwiftUI

struct PlaceHolderView: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 50))
                .padding()
                .foregroundColor(.secondary)
            Text(title)
                .font(.title3)
                .bold()
            Spacer()
        }
    }
}
