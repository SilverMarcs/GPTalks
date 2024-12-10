//
//  MockedData.swift
//  GPTalks
//
//  Created by Zabir Raihan on 29/09/2024.
//

import Foundation

extension Provider {
    static var openAIProvider = Provider.factory(type: .openai)
    static var googleProvider = Provider.factory(type: .google)
    static var anthropicProvider = Provider.factory(type: .anthropic)
    
    static var mockProviders = [
        openAIProvider,
        googleProvider,
        anthropicProvider,
    ]
}

extension ProviderDefaults {
    static var mockProviderDefaults = ProviderDefaults(defaultProvider: .openAIProvider, quickProvider: .openAIProvider, imageProvider: .openAIProvider, sttProvider: .openAIProvider)
}

extension AIModel {
    static var gpt4 = AIModel(code: "gpt", name: "GPT-4", type: .chat)
}

extension AIModel {
    static var dalle = AIModel(code: "dall-e-3", name: "DALL-E-3", type: .image)
}

extension AIModel {
    static var whisper = AIModel(code: "whisper-1", name: "Whisper-1", type: .stt)
}

extension Message {
    static let mockAssistantMessage = Message(role: .assistant, content: String.codeBlock, isReplying: false)
    
    static let mockAssistantTolCallMessage = Message(role: .assistant, toolCalls: [.init(toolCallId: "HEX", tool: .urlScrape, arguments: "url: https://www.google.com")])
    
    static var mockUserMessage: Message {
        Message(role: .user, content: String.shortContent)
    }
    
    static var mockToolMessage: Message {
        Message(role: .tool, toolResponse: .init(toolCallId: "HEX", tool: .urlScrape, processedContent: "This is what I got"))
    }
}

extension MessageGroup {
    static var mockUserGroup = MessageGroup(message: .mockUserMessage)
    static var mockAssistantGroup = MessageGroup(message: .mockAssistantMessage)
    static var mockToolGroup = MessageGroup(message: .mockToolMessage)
    static var mockAssistantToolCallGroup = MessageGroup(message: .mockAssistantTolCallMessage)
}

extension ChatConfig {
    static var mockChatConfig = ChatConfig(provider: .openAIProvider, purpose: .chat)
}

extension ImageConfig {
    static var mockImageConfig = ImageConfig(prompt: "New York City", provider: .openAIProvider, model: .dalle)
}

extension Chat {
    static var mockChat = Chat(config: .mockChatConfig)
}

extension ImageSession {
    static var mockImageSession = ImageSession(config: .mockImageConfig)
}

extension Generation {
    static var mockGeneration: Generation = .init(config: .mockImageConfig, session: .mockImageSession)
}

extension ChatVM {
    static var mockChatVM = ChatVM()
}

extension ImageVM {
    static var mockImageVM = ImageVM()
}


extension String {
    static let markdownContent = """
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
    
    static let demoAssistant: String =
    """
    ## Heading   
    There are three ways to print a string in python
    1. Not printing
    2. Printing carelessly
    3. Blaming it on Teammates
    
    ### Subheading
    But whats even better is the ability to see into the future.  
        
    Thank you for using me.
    """
    
    static let codeBlock = """
    This is a sample amrkdown string
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
    
    static var onlyCodeBlock = """
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
    """
    
    static let shortContent = """
        Hello, World! Could you show me some unstructured text formatted in markdown?
        """
    
    static let properMarkdown = """
The error you're encountering is because you're trying to call a mutating function (`visit`) on `self` within a non-mutating context. In Swift, the `mutating` keyword indicates that the function modifies the instance it belongs to, and such methods can only be called on mutable instances.

To resolve this, you need to refactor your code to ensure that `visit` does not require a mutating context, or alternatively, refactor the logic so that the `visit` function is called outside of contexts where `self` is immutable.

### Solution: Refactor `visit` Function

Let's assume `visit` is a function that traverses a `ListItem` and returns an `NSAttributedString`. You should ensure that this function is non-mutating, or you separate the logic such that `visit` does not capture `self` in a way that requires it to be mutable.

Here's how you can refactor your code:

1. **Ensure `visit` is Non-Mutating**: If possible, modify the `visit` function so it does not require mutating `self`.

```swift
func visit(_ markup: Markup) -> NSAttributedString {
    // Your logic to convert markup to NSAttributedString
    // This logic should not depend on mutating self
    return NSAttributedString(string: markup.format())
}
```

2. **Refactor `parserResults`**: If `visit` inherently requires mutating behavior, consider separating the logic into a non-mutating context:

```swift
mutating func parserResults(from document: Document, highlightText: String) -> [ContentItem] {
    var results = [ContentItem]()
    var currentTextBuffer = NSMutableAttributedString()
    
    func appendCurrentAttrString() {
        if !currentTextBuffer.string.isEmpty {
            applyHighlighting(to: currentTextBuffer, highlightText: highlightText)
            results.append(.text(currentTextBuffer))
            currentTextBuffer = NSMutableAttributedString()
        }
    }
    
    func mapListItems(_ listItems: LazyMapSequence<MarkupChildren, ListItem>) -> [ListItemContent] {
        listItems.map { listItem in
            let text = visit(listItem) // Ensure `visit` is non-mutating
            return ListItemContent(text: text, checkbox: listItem.checkbox)
        }
    }
    
    document.children.forEach { markup in
        if let codeBlock = markup as? CodeBlock {
            appendCurrentAttrString()
            results.append(.codeBlock(codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines), language: codeBlock.language))
        } else if let table = markup as? Table {
            appendCurrentAttrString()
            results.append(.table(table))
        } else if let orderedList = markup as? OrderedList {
            appendCurrentAttrString()
            let listItems = mapListItems(orderedList.listItems)
            results.append(.list(.ordered, listItems))
        } else if let unorderedList = markup as? UnorderedList {
            appendCurrentAttrString()
            let listItems = mapListItems(unorderedList.listItems)
            results.append(.list(.unordered, listItems))
        } else {
            let visitedText = visit(markup)
            currentTextBuffer.append(visitedText)
        }
    }
    
    appendCurrentAttrString()
    
    return results
}
```

### Explanation

- **Non-Mutating `visit`**: Ensure `visit` does not need to modify `self`. It should be a pure function that takes a `Markup` and returns an `NSAttributedString`.
- **Separate Logic**: If `visit` must remain mutating, try to refactor your code to call `visit` in contexts where you have a mutable `self`, or redesign your data flow to avoid such requirements.

By ensuring `visit` is non-mutating or restructuring your code to avoid mutating contexts, you can resolve this error.
"""

}
