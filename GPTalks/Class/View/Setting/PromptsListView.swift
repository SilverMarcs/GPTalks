//
//  PromptsListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/31.
//

import SwiftUI

struct PromptsListView: View {
    
    @ObservedObject var manager = PromptManager.shared
    
    @State var selectedPrompt: Prompt?
                
    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading) {
            List {
                Section {
                    ForEach(manager.syncedPrompts.sorted(by: {
                        $0.act < $1.act
                    })) { prompt in
                        VStack {
                            HStack {
                                Text(prompt.act)
                                Spacer()
                                Button {
                                    if selectedPrompt == prompt {
                                        selectedPrompt = nil
                                    } else {
                                        selectedPrompt = prompt
                                    }
                                } label: {
                                    if selectedPrompt == prompt {
                                        Image(systemName: "arrowtriangle.up.circle")
                                    } else {
                                        Image(systemName: "info.circle")
                                    }
                                }
                                .buttonStyle(.borderless)
                            }
                            if selectedPrompt == prompt {
                                PromptDetailView(prompt: prompt)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.systemBackground)
                            }
                        }
                    }
                }
            }
            .listStyle(.bordered(alternatesRowBackgrounds: false))
        }
        #else
        List {
            Section {
                ForEach(manager.syncedPrompts.sorted(by: {
                    $0.act < $1.act
                })) { prompt in
                    NavigationLink {
                        PromptDetailView(prompt: prompt)
                    } label: {
                        Text(prompt.act)
                    }

                }
            }
        }
        .navigationTitle("Prompts")
        #endif
    }
}

struct PromptDetailView: View {
    
    let prompt: Prompt
    
    var body: some View {
#if os(iOS)
        Form {
            Section {
                HStack {
                    Image(systemName: "terminal.fill")
                    Text("/\(prompt.cmd)")
                }
                
            }
            Section("Prompt") {
                Text(prompt.prompt)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle(prompt.act)
#else
        Form {
            Section {
                HStack {
                    Image(systemName: "terminal.fill")
                    Text("/\(prompt.cmd)")
                        .textSelection(.enabled)
                    Spacer()
                }
            }
            .padding(.bottom)
            Section {
                Text(prompt.prompt)
                    .textSelection(.enabled)
            }
        }
        .padding()
#endif
    }
    
}

struct PromptsListView_Previews: PreviewProvider {
    static var previews: some View {
        PromptsListView()
    }
}

//extension TimeInterval {
//    
//    var date: Date {
//        Date(timeIntervalSince1970: self)
//    }
//    
//    var dateDesc: String {
//        if date == .distantPast {
//            return String(localized: "Never")
//        }
//        return String(localized: "Last updated on \(date.dateTimeString())")
//    }
//    
//}
