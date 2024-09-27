//
//  MarkdownSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI
import MarkdownWebView

struct MarkdownSettings: View {
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        Form {
            Picker("Markdown Provider", selection: $config.markdownProvider) {
                ForEach(MarkdownProvider.allCases, id: \.self) { provider in
                    Text(provider.name)
                }
            }
            
//            if config.markdownProvider != .native || config.markdownProvider != .disabled {
//                Picker("Codeblock Theme", selection: $config.markdownTheme) {
//                    ForEach(MarkdownTheme.allCases, id: \.self) { theme in
//                        Text(theme.name)
//                    }
//                }
//            }
            
            Section("Demo") {
                MarkdownView(conversation: Conversation(role: .assistant, content: codeBlock))
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
    }
    
    let codeBlock = """
    - Sorts a list and prints the sorted list
    - Profit
    
    ```python
    def quick_sort(arr):
        if len(arr) <= 1:
            return arr
        else:
            pivot = arr[0]
            less_than_pivot = [x for x in arr[1:] if x <= pivot]
            greater_than_pivot = [x for x in arr[1:] if x > pivot]
            return quick_sort(less_than_pivot) + [pivot] + quick_sort(greater_than_pivot)

    # Example usage
    my_list = [3, 6, 8, 10, 1, 2, 1]
    sorted_list = quick_sort(my_list)
    print(sorted_list)
    ```
    1. Sort a list and print the sorted list
    2. Profit
    """
}

#Preview {
    MarkdownSettings()
}
