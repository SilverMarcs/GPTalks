//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownWebView

struct MarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    var conversation: Conversation
    
    var highlightString: String? {
        conversation.group?.session?.searchText.count ?? 0 > 3 ? conversation.group?.session?.searchText : nil
    }
    
    @State var isRendered = false
    
    var body: some View {
        switch config.markdownProvider {
            case .webview:
            if !isRendered {
                ProgressView()
            }
            
            MarkdownWebView(conversation.content,
                            baseURL: "GPTalks Web Content",
                            highlightString: highlightString,
                            customStylesheet: config.markdownTheme,
                            fontSize: CGFloat(config.fontSize))
            .onRendered { content in
                isRendered = true
            }
            case .native:
                Text(LocalizedStringKey(conversation.content))
                .font(.system(size: config.fontSize))
            case .disabled:
                Text(conversation.content)
                .font(.system(size: config.fontSize))
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
