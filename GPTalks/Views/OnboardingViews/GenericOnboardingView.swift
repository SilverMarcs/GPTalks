//
//  GenericOnboardingView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct GenericOnboardingView<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: () -> Content
    let footerText: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // Icon and Title
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.system(size: geometry.size.height * 0.1))
                    
                    Text(title)
                        .font(.title)
                        .bold()
                }
                .frame(height: geometry.size.height * 0.25)
                
                // Content
                content()
                    .frame(height: geometry.size.height * 0.4)
                
                Spacer()
                
                // Footer
                Text(footerText)
                    .italic()
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
    }
}
