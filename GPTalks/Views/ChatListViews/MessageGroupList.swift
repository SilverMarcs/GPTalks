//
//  MessageGroupList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/11/2024.
//

import SwiftUI
import SwiftData

struct MessageGroupList: View {
    @Environment(ChatVM.self) var chatVM
    
    @Query var messageGroups: [MessageGroup]
    var searchText: String
    
    var body: some View {
        let groupedMessageGroups = Dictionary(grouping: messageGroups.filter { $0.chat != nil }) { $0.chat! }
        
        return List {
            ForEach(groupedMessageGroups.keys.sorted(by: { $0.id < $1.id }), id: \.self) { chat in
                Section(chat.title) {
                    ForEach(groupedMessageGroups[chat] ?? []) { group in
                        Button {
                            let delay = chatVM.activeChat == chat ? 0 : 0.2
                            
                            chatVM.selections = [chat]
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                Scroller.scroll(to: .top, of: group)
                            }
                        } label: {
                            // TODO: show attachment icon if group has attachments
                            HighlightableTextView(text: getContextAroundMatch(content: group.activeMessage.content, searchText: searchText), highlightedText: searchText)
                                .font(.system(size: 13))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .contentShape(RoundedRectangle(cornerRadius: 8))
                                .opacity(0.8)
                        }
                        .buttonStyle(ClickHighlightButton())
                    }
                }
            }
        }
    }
    
    init(searchText: String) {
        self.searchText = searchText
        let predicate = #Predicate<MessageGroup> { group in
            group.chat != nil && group.activeMessage.content.localizedStandardContains(searchText)
        }
        _messageGroups = Query(filter: predicate)
    }
    
    private func getContextAroundMatch(content: String, searchText: String) -> String {
        let limit = 80
        
        guard !searchText.isEmpty else {
            return String(content.prefix(limit))
        }
        
        if let range = content.range(of: searchText, options: .caseInsensitive) {
            let matchLength = min(searchText.count, limit)
            let remainingLength = limit - matchLength
            
            let preMatchStart = content.index(range.lowerBound, offsetBy: -remainingLength/2, limitedBy: content.startIndex) ?? content.startIndex
            let postMatchEnd = content.index(range.lowerBound, offsetBy: matchLength + remainingLength/2, limitedBy: content.endIndex) ?? content.endIndex
            
            var result = String(content[preMatchStart..<postMatchEnd])
            
            // Trim or pad the result to exactly 40 characters
            if result.count > limit {
                result = String(result.prefix(limit))
            } else if result.count < limit {
                let padding = String(repeating: " ", count: limit - result.count)
                result += padding
            }
            
            return result
        } else {
            return String(content.prefix(limit))
        }
    }
}
