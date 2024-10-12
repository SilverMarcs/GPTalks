//
//  ScrollUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/10/2024.
//

import SwiftUI

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
