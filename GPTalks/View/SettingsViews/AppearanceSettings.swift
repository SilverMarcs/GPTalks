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
    
    @State var session: ChatSession?

    var body: some View {
        Form {
            Section("Font Size") {
                HStack {
                    Button("Reset") {
                        config.resetFontSize()
                    }
                    Slider(value: $config.fontSize, in: 8...25, step: 1) {
                        Text("Font Size")
                    } minimumValueLabel: {
                        Text("")
                            .monospacedDigit()
                    } maximumValueLabel: {
                        Text(String(config.fontSize))
                            .monospacedDigit()
                    }
                }
            }
            
            #if os(macOS)
            Section("Status Bar") {
                Toggle("Show Status Bar", isOn: $config.showStatusBar)
            }
            #endif

            Section("View Customisation") {
                Picker(selection: $config.sidebarIconSize) {
                    ForEach(SidebarIconSize.allCases, id: \.self) { size in
                        Text(size.rawValue.capitalized)
                    }
                } label: {
                    Text("Sidebar Icon Size")
                    Text("System will follow value in MacOS ppearance settings")
                }
                    .task {
                        fetchSession()
                    }
                
                    if let session = session {
                        HStack(alignment: .top) {
                            Text("Demo")
                            
                            Spacer()
                            
                            GroupBox {
                                SessionListRow(session: session)
                                    .padding(6)
                            }
                            .frame(maxWidth: 220)
                            .groupBoxStyle(PlatformSpecificGroupBoxStyle())
                        }
                    }

                #if os(macOS)
                Picker(selection: $config.conversationListStyle) {
                    ForEach(ConversationListStyle.allCases, id: \.self) { style in
                        Text(style.rawValue)
                    }
                } label: {
                    Text("ConversationList Style")
                    Text("List View is smoother but some features may not function.")
                }
                .pickerStyle(.radioGroup)
                #endif
            }
            
            Section("List Truncation") {
                Toggle("Show Less Sessions", isOn: $config.truncateList)

                IntegerStepper(value: $config.listCount, label: "List Count", step: 1, range: 6...20)
                .opacity(config.truncateList ? 1 : 0.5)
                .disabled(!config.truncateList)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .toolbarTitleDisplayMode(.inline)
    }
    
    private func fetchSession() {
        var descriptor = FetchDescriptor<ChatSession>()
        
        descriptor.fetchLimit = 1
        
        do {
            let sessions = try modelContext.fetch(descriptor)
            session = sessions.first
        } catch {
            print("Error fetching quick session: \(error)")
        }
    }
}

#Preview {
    AppearanceSettings()
}

