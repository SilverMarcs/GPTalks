//
//  Scroller.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

// TODO: Deprecate this
func scrollToBottom(proxy: ScrollViewProxy, id: String = String.bottomID, anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
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

struct Scroller<ID: Hashable> {
    static func scroll(to anchor: UnitPoint, of id: ID, animated: Bool = true, delay: TimeInterval = 0.0) {
        let action = {
            if let proxy = AppConfig.shared.proxy {
                if animated {
                    withAnimation {
                        proxy.scrollTo(id, anchor: anchor)
                    }
                } else {
                    proxy.scrollTo(id, anchor: anchor)
                }
            }
        }
        
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
    
    static func scrollToBottom(id: ID = String.bottomID, animated: Bool = true, delay: TimeInterval = 0.0) {
        scroll(to: .bottom, of: id, animated: animated, delay: delay)
    }
}
