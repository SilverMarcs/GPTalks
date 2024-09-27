//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownWebView

struct MarkdownView: View {
    @Environment(\.isQuick) var isQuick
    @Environment(SessionVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    var conversation: Conversation
    
    var highlightString: String? {
        sessionVM.searchText.count > 3 ? sessionVM.searchText : nil
    }
    
    var body: some View {
        let provider = isQuick ? config.quickMarkdownProvider : config.markdownProvider
        
        switch provider {
            case .webview:
                MarkdownWebView(conversation.content,
                                baseURL: "GPTalks Web Content",
                                highlightString: highlightString,
                                customStylesheet: config.markdownTheme,
                                fontSize: CGFloat(config.fontSize))
            case .native:
                Text(LocalizedStringKey(conversation.content))
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
            case .disabled:
                Text(conversation.content)
                    .font(.system(size: config.fontSize))
                    .textSelection(.enabled)
        }
    }
}



#Preview {
    let content = """
    Certainly! In Python, you can sort data using the built-in `sort()` method for lists or the `sorted()` function. Below are examples of both methods along with explanations.

    ### Using `sort()` Method

    The `sort()` method sorts a list in place. This means that it modifies the original list and does not return a new list.

    ```python
    # Example of using sort() method
    numbers = [5, 2, 9, 1, 5, 6]
    numbers.sort()  # Sorts the list in place
    print("Sorted numbers (in place):", numbers)
    ```

    ## Summary

    - Use `list.sort()` to sort a list in place.
    - Use `sorted(iterable)` to get a new sorted list without changing the original.
    - Use `reverse=True` for descending order.
    - Use the `key` parameter to sort based on custom criteria.

    Feel free to adjust the examples or ask if you have a specific sorting scenario in mind!
    """
    let conversation = Conversation(role: .assistant, content: content)
    
    MarkdownView(conversation: conversation)
        .frame(width: 600, height: 500)
        .padding()
}
