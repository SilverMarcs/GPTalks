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
    let table: Markdown.Table
    
    var body: some View {
//        ZStack(alignment: .topLeading) {
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
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .roundedRectangleOverlay(radius: 6)
            
//            CustomCopyButton(content: formattedTableContent())
//        }
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
//struct DynamicTableRow: Identifiable {
//    let id = UUID()
//    var attr1: String = ""
//    var attr2: String = ""
//    var attr3: String = ""
//    var attr4: String = ""
//    var attr5: String = ""
//    var attr6: String = ""
//    var attr7: String = ""
//    var attr8: String = ""
//    var attr9: String = ""
//    var attr10: String = ""
//}
//
//struct TableView: View {
//    @Environment(ChatVM.self) var chatVM
//    @Environment(\.isReplying) var isReplying
//    @ObservedObject var config = AppConfig.shared
//    let table: Markdown.Table
//    
//    @State private var rows: [DynamicTableRow] = []
//    @State private var headers: [String] = []
//    
//    let rowCount: Int
//    
//    init(table: Markdown.Table) {
//        self.table = table
//        self.rowCount = table.body.childCount
//    }
//    
//    var body: some View {
//        if isReplying {
//            Text("Populating Table...")
//                .foregroundStyle(.secondary)
//                .padding(.leading)
//        } else {
//            tableView
//        }
//    }
//    
//    var tableView: some View {
//        Table(rows) {
//            if headers.indices.contains(0) && !headers[0].isEmpty {
//                TableColumn(headers[0]) {
//                    HighlightableTextView($0.attr1, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(1) && !headers[1].isEmpty {
//                TableColumn(headers[1]) {
//                    HighlightableTextView($0.attr2, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(2) && !headers[2].isEmpty {
//                TableColumn(headers[2]) {
//                    HighlightableTextView($0.attr3, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(3) && !headers[3].isEmpty {
//                TableColumn(headers[3]) {
//                    HighlightableTextView($0.attr4, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(4) && !headers[4].isEmpty {
//                TableColumn(headers[4]) {
//                    HighlightableTextView($0.attr5, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(5) && !headers[5].isEmpty {
//                TableColumn(headers[5]) {
//                    HighlightableTextView($0.attr6, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(6) && !headers[6].isEmpty {
//                TableColumn(headers[6]) {
//                    HighlightableTextView($0.attr7, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(7) && !headers[7].isEmpty {
//                TableColumn(headers[7]) {
//                    HighlightableTextView($0.attr8, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(8) && !headers[8].isEmpty {
//                TableColumn(headers[8]) {
//                    HighlightableTextView($0.attr9, highlightedText: chatVM.searchText)
//                }
//            }
//            if headers.indices.contains(9) && !headers[9].isEmpty {
//                TableColumn(headers[9]) {
//                    HighlightableTextView($0.attr10, highlightedText: chatVM.searchText)
//                }
//            }
//        }
//        .scrollDisabled(true)
//        .frame(height: CGFloat(rowCount + 1) * 25.7) // +1 for the header row
////        .font(.system(size: AppConfig.shared.fontSize)) // cant do since fixed height rows
//        .clipShape(RoundedRectangle(cornerRadius: 6))
//        .roundedRectangleOverlay(radius: 6)
//        .task {
//            await populateTableData()
//        }
//    }
//    
//    private func populateTableData() async {
//        // sleep for 0.1s
//        try? await Task.sleep(nanoseconds: 100_000_000)
//        // Populate headers
//        headers = (0..<table.head.childCount).map { index in
//            cellText(for: table.head.child(at: index) as! Markdown.Table.Cell)
//        }
//        
//        // Populate rows
//        rows = (0..<table.body.childCount).map { rowIndex in
//            let row = table.body.child(at: rowIndex) as! Markdown.Table.Row
//            var dynamicRow = DynamicTableRow()
//            
//            for cellIndex in 0..<row.childCount {
//                let cellText = cellText(for: row.child(at: cellIndex) as! Markdown.Table.Cell)
//                switch cellIndex {
//                case 0: dynamicRow.attr1 = cellText
//                case 1: dynamicRow.attr2 = cellText
//                case 2: dynamicRow.attr3 = cellText
//                case 3: dynamicRow.attr4 = cellText
//                case 4: dynamicRow.attr5 = cellText
//                case 5: dynamicRow.attr6 = cellText
//                case 6: dynamicRow.attr7 = cellText
//                case 7: dynamicRow.attr8 = cellText
//                case 8: dynamicRow.attr9 = cellText
//                case 9: dynamicRow.attr10 = cellText
//                default: break
//                }
//            }
//            
//            return dynamicRow
//        }
//    }
//    
//    private func cellText(for cell: Markdown.Table.Cell) -> String {
//        cell.children.compactMap { ($0 as? Markdown.Text)?.plainText }.joined()
//    }
//}
