//
//  ConversationListExtended.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import IsScrolling

extension View {
    func applyObservers(proxy: ScrollViewProxy, session: Session, hasUserScrolled: Binding<Bool>, isScrolling: Binding<Bool>) -> some View {
        self
            .onAppear {
                scrollToBottom(proxy: proxy, delay: 0.2)
                scrollToBottom(proxy: proxy, delay: 0.4)
            }
            .onChange(of: session.unorderedGroups.last?.activeConversation.content) {
                if isScrolling.wrappedValue == true {
                    hasUserScrolled.wrappedValue = true
                }
                
                if !hasUserScrolled.wrappedValue {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isReplying) {
                if !session.isReplying  {
                    hasUserScrolled.wrappedValue = false
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.unorderedGroups.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.errorMessage) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.inputManager.prompt) {
                scrollToBottom(proxy: proxy)
            }
    }
}

func scrollToBottom(proxy: ScrollViewProxy, id: String = .bottomID, anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
    let action = {
        if animated {
            withAnimation {
                proxy.scrollTo(id, anchor: anchor)
            }
        } else {
            proxy.scrollTo(id, anchor: anchor)
        }
    }
    
    if delay > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    } else {
        DispatchQueue.main.async(execute: action)
    }
}
