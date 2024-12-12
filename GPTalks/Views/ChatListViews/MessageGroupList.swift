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
                Section {
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
                } header: {
                    HStack {
                        Image(systemName: chat.status.systemImageName)
                        Text(chat.title)
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
        
        // First, normalize the content by replacing newlines with spaces and removing excess whitespace
        let normalizedContent = content.replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        guard !searchText.isEmpty else {
            let truncated = String(normalizedContent.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizedContent.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
        
        if let range = normalizedContent.range(of: searchText, options: .caseInsensitive) {
            let matchLength = min(searchText.count, limit)
            let remainingLength = limit - matchLength
            
            let preMatchStart = normalizedContent.index(range.lowerBound, offsetBy: -remainingLength/2, limitedBy: normalizedContent.startIndex) ?? normalizedContent.startIndex
            let postMatchEnd = normalizedContent.index(range.lowerBound, offsetBy: matchLength + remainingLength/2, limitedBy: normalizedContent.endIndex) ?? normalizedContent.endIndex
            
            var result = String(normalizedContent[preMatchStart..<postMatchEnd])
            
            if result.count > limit {
                result = String(result.prefix(limit))
            }
            
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let needsLeadingEllipsis = preMatchStart > normalizedContent.startIndex
            let needsTrailingEllipsis = postMatchEnd < normalizedContent.endIndex
            
            if needsLeadingEllipsis {
                result = ellipsis + result
            }
            if needsTrailingEllipsis {
                result = result + ellipsis
            }
            
            return result
        } else {
            let truncated = String(normalizedContent.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizedContent.count > limit ? ellipsis + truncated + ellipsis : truncated
        }
    }
}
