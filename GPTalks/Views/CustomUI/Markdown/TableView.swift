//
//  TableView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI
import Markdown

struct TableView: View {
    @Environment(ChatVM.self) var chatVM
    @ObservedObject var config = AppConfig.shared
    let table: Markdown.Table
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    ForEach(0..<table.head.childCount, id: \.self) { index in
                        HighlightableTextView(cellText(for: table.head.child(at: index) as! Markdown.Table.Cell), highlightedText: chatVM.searchText)
                            .font(.headline)
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            .background(.background.tertiary)
                    }
                }
                
                // Body
                ForEach(0..<table.body.childCount, id: \.self) { rowIndex in
                    let row = table.body.child(at: rowIndex) as! Markdown.Table.Row
                    HStack(spacing: 0) {
                        ForEach(0..<row.childCount, id: \.self) { cellIndex in
                            HighlightableTextView(cellText(for: row.child(at: cellIndex) as! Markdown.Table.Cell), highlightedText: chatVM.searchText)
                                .padding(4)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(rowIndex % 2 == 0 ? AnyShapeStyle(.background) : AnyShapeStyle(.background.secondary))
                }
            }
            .font(.system(size: AppConfig.shared.fontSize))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .roundedRectangleOverlay(radius: 6)
            
            CustomCopyButton(content: formattedTableContent())
        }
    }
    
    private func cellText(for cell: Markdown.Table.Cell) -> String {
        cell.children.compactMap { ($0 as? Markdown.Text)?.plainText }.joined()
    }
    
    private func formattedTableContent() -> String {
        var content = ""
        
        // Header
        for i in 0..<table.head.childCount {
            let cell = table.head.child(at: i) as! Markdown.Table.Cell
            content += cellText(for: cell)
            content += (i < table.head.childCount - 1) ? " | " : "\n"
        }
        
        // Separator
        content += String(repeating: "-", count: content.count) + "\n"
        
        // Body
        for i in 0..<table.body.childCount {
            let row = table.body.child(at: i) as! Markdown.Table.Row
            for j in 0..<row.childCount {
                let cell = row.child(at: j) as! Markdown.Table.Cell
                content += cellText(for: cell)
                content += (j < row.childCount - 1) ? " | " : "\n"
            }
        }
        
        return content
    }
}
