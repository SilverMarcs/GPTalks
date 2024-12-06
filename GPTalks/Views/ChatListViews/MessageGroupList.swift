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
    @State private var selectedGroupID: MessageGroup.ID?
    
    var body: some View {
        let groupedMessageGroups = Dictionary(grouping: messageGroups.filter { $0.chat != nil }) { $0.chat! }
        
        return List {
            ForEach(groupedMessageGroups.keys.sorted(by: { $0.date > $1.date }), id: \.self) { chat in
                Section(chat.title) {
                    ForEach(groupedMessageGroups[chat]?.sorted(by: { $0.date < $1.date }) ?? []) { group in
                        Button {
                            let delay = chatVM.activeChat == chat ? 0 : 0.2
                            
                            chatVM.selections = [chat]
                            selectedGroupID = group.id
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                Scroller.scroll(to: .top, of: group)
                            }
                        } label: {
                            HighlightableTextView(getContextAroundMatch(content: group.activeMessage.content, searchText: searchText), highlightedText: searchText)
                                .font(.system(size: 13))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(0.8)
                                .contentShape(Rectangle())
                            
                        }
                        .padding(.horizontal, -4)
                        .buttonStyle(SelectedButtonStyle(isSelected: Binding(
                            get: { selectedGroupID == group.id },
                            set: { _ in }
                        )))
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
        let ellipsis = "..."
        
        guard !searchText.isEmpty else {
            let truncated = String(content.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return content.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
        
        if let range = content.range(of: searchText, options: .caseInsensitive) {
            let matchLength = min(searchText.count, limit)
            let remainingLength = limit - matchLength
            
            let preMatchStart = content.index(range.lowerBound, offsetBy: -remainingLength/2, limitedBy: content.startIndex) ?? content.startIndex
            let postMatchEnd = content.index(range.lowerBound, offsetBy: matchLength + remainingLength/2, limitedBy: content.endIndex) ?? content.endIndex
            
            var result = String(content[preMatchStart..<postMatchEnd])
            
            // Trim the result to exactly 80 characters if it exceeds
            if result.count > limit {
                result = String(result.prefix(limit))
            }
            
            // Remove leading and trailing whitespaces or newlines
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Add ellipsis if truncation occurred
            let needsLeadingEllipsis = preMatchStart > content.startIndex
            let needsTrailingEllipsis = postMatchEnd < content.endIndex
            
            if needsLeadingEllipsis {
                result = ellipsis + result
            }
            if needsTrailingEllipsis {
                result = result + ellipsis
            }
            
            return result
        } else {
            let truncated = String(content.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return content.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
    }
}
