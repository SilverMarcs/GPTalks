//
//  AboutSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutSettings: View {
    var body: some View {
        Form {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image("AppIconPng")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                    
                Text("GPTalks")
                    .font(.title.bold())
                
                Text("Multi-LLM API client written in SwiftUI")
                    .font(.subheadline)
                
                Text(getAppVersion())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Made by SilverMarcs")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
            }
            
            Section("Connect") {
                LabeledContent{
                    Link("Github Repository", destination: URL(string: "https://github.com/SilverMarcs/GPTalks")!)
                } label: {
                    Text("\(Image(systemName: "link")) Source Code")
                }
                
                
                
                LabeledContent {
                    Link("Follow on X.com", destination: URL(string: "https://twitter.com/SilverMarcs3")!)
                } label: {
                    Text("\(Image(systemName: "person")) Social Profile")
                }
            }
            
            Section("Acknowledgements") {
                ForEach(Acknowledgement.acknowledgements, id: \.name) { acknowledgement in
                    Link(destination: URL(string: acknowledgement.url)!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(acknowledgement.name)
                                    .font(.headline)
                                Text(acknowledgement.description)
                                    .multilineTextAlignment(.leading)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
        .toolbarTitleDisplayMode(.inline)
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
           {
            return "Version \(version)"
        }
        return "Version Unknown"
    }

}

#Preview {
    AboutSettings()
        .frame(width: 500)
}
