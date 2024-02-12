//
//  AppIconView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 29/11/2023.
//

import SwiftUI

#if !os(macOS)
struct AppIconView: View {
    @State private var selectedIconName: String = "AppIconPurple" // Default selected icon
    
    var body: some View {
        Form {
            Section {
                SelectableRow(iconName: "AppIconPurple", selectedIconName: $selectedIconName, label: "Purple Icon")
                SelectableRow(iconName: "AppIconPink", selectedIconName: $selectedIconName, label: "Pink Icon")
            }
            .navigationTitle("App Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SelectableRow: View {
    let iconName: String
    @Binding var selectedIconName: String
    let label: String
    
    var body: some View {
        HStack {
            // Display the app icon image
            if let uiImage = UIImage(named: iconName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: "app.fill") // Fallback icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            
            Text(label)
            Spacer()
            if selectedIconName == iconName {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedIconName = iconName
            changeAppIcon(to: iconName)
        }
    }
    
    private func changeAppIcon(to iconName: String) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting alternate icon \(error.localizedDescription)")
            } else {
                // Icon changed successfully
            }
        }
    }
}

#Preview {
    AppIconView()
}
#endif
