//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI
import SwiftData

struct AppearanceSettings: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @State var session: Session?

    var body: some View {
        Form {
            Section("Font Size") {
                Slider(value: $config.fontSize, in: 8...25, step: 1) {
                    HStack {
                        Button("Reset") {
                            config.resetFontSize()
                        }
                    }
                } minimumValueLabel: {
                    Text("")
                        .monospacedDigit()
                } maximumValueLabel: {
                    Text(String(config.fontSize))
                        .monospacedDigit()
                }
            }

            Section("View Customisation") {
                Toggle("Compact List Row", isOn: $config.compactList)
                
                if let session = session {
                    HStack(alignment: .top) {
                        Text("Demo")
                        
                        Spacer()
                        
                        SessionListRow(session: session)
                            .frame(maxWidth: 220)
                            .bubbleStyle(radius: 7, padding: 4)
                    }
                }
                
                #if os(macOS)
                VStack(alignment: .leading) {
                    Picker("ConversationList Style", selection: $config.conversationListStyle) {
                        ForEach(ConversationListStyle.allCases, id: \.self) { style in
                            Text(style.rawValue)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    
                    Text("List View is smoother but some features may not function.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                #endif
            }
            
            Section("List Truncation") {
                Toggle("Show Less Sessions", isOn: $config.truncateList)

                IntegerStepper(value: $config.listCount, label: "List Count", step: 1, range: 6...20)
                .opacity(config.truncateList ? 1 : 0.5)
                .disabled(!config.truncateList)
            }
        }
        .onAppear {
            fetchQuickSession()
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private func fetchQuickSession() {
        var descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { $0.isQuick == true }
        )
        
        descriptor.fetchLimit = 1
        
        do {
            let quickSessions = try modelContext.fetch(descriptor)
            session = quickSessions.first
        } catch {
            print("Error fetching quick session: \(error)")
        }
    }
}

#Preview {
    AppearanceSettings()
}

