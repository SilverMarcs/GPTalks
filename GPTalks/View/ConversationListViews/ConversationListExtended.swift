//
//  ConversationListExtended.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

extension View {
    func applyObservers(proxy: ScrollViewProxy, session: Session, hasUserScrolled: Binding<Bool>, isScrolling: Binding<Bool>) -> some View {
        self
        #if os(macOS)
            .onAppear {
                scrollToBottom(proxy: proxy, delay: 0.2)
                scrollToBottom(proxy: proxy, delay: 0.4)
            }
        #endif
            .onChange(of: session.groups.last?.activeConversation.content) {
                if !hasUserScrolled.wrappedValue && session.isStreaming {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.isStreaming) {
                if !session.isStreaming  {
                    hasUserScrolled.wrappedValue = false
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.groups.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.errorMessage) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.inputManager.prompt) {
                if session.inputManager.state == .normal {
                    scrollToBottom(proxy: proxy)
                }
            }
        #if canImport(UIKit)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy)
            }
        #endif
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
