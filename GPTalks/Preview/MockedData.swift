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
    static var vertexProvider = Provider.factory(type: .vertex)
    static var localProvider = Provider.factory(type: .local)
    
    static var mockProviders = [
        openAIProvider,
        googleProvider,
        anthropicProvider,
        vertexProvider,
        localProvider
    ]
}

extension ChatModel {
    static var gpt4 = ChatModel(code: "gpt", name: "GPT-4")
}

extension ImageModel {
    static var dalle = ImageModel(code: "dall-e-3", name: "DALL-E-3")
}

extension STTModel {
    static var whisper = STTModel(code: "whisper-1", name: "Whisper-1")
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
    This is a code block
    
    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    ```
    
    Thank you for using me.
    
    """
    
    static let shortContent = """
        Hello, World! Hi boss How are you boss today please tell me 
        """
}

extension Conversation {
    static let mockAssistantConversation = Conversation(role: .assistant, content: String.codeBlock)
    
    static let mockAssistantTolCallConversation = Conversation(role: .assistant, toolCalls: [.init(toolCallId: "HEX", tool: .urlScrape, arguments: "url: https://www.google.com")])
    
    static var mockUserConversation: Conversation {
        Conversation(role: .user, content: String.shortContent)
    }
    
    static var mockToolConversation: Conversation {
        Conversation(role: .tool, toolResponse: .init(toolCallId: "HEX", tool: .urlScrape, processedContent: "This is what I got"))
    }
}

extension SessionConfig {
    static var mockChatConfig = SessionConfig(provider: .openAIProvider, purpose: .chat)
}

extension ImageConfig {
    static var mockImageConfig = ImageConfig(provider: .openAIProvider, model: .dalle)
}

extension ChatSession {
    static var mockChatSession = ChatSession(config: .mockChatConfig)
}

extension ImageSession {
    static var mockImageSession = ImageSession(config: .mockImageConfig)
}

extension ImageGeneration {
    static var mockImageGeneration: ImageGeneration = .init(prompt: "New York City", config: .mockImageConfig, session: .mockImageSession)
}

extension ConversationGroup {
    static var mockUserConversationGroup: ConversationGroup {
        let userConversation = Conversation.mockUserConversation
        let session = ChatSession.mockChatSession
        return ConversationGroup(conversation: userConversation, session: session)
    }
    
    static var mockAssistantConversationGroup: ConversationGroup {
        let assistantConversation = Conversation.mockAssistantConversation
        let session = ChatSession.mockChatSession
        return ConversationGroup(conversation: assistantConversation, session: session)
    }
}

extension ChatSessionVM {
    static var mockSessionVM = ChatSessionVM(modelContext: DatabaseService.shared.modelContext)
}

extension ImageSessionVM {
    static var mockImageSessionVM = ImageSessionVM(modelContext: DatabaseService.shared.modelContext)
}
