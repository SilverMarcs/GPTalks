//
//  Extnsions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    // does chunking from bottom up
    func chunked(fromEndInto size: Int) -> [[Element]] {
        reversed().chunked(into: size).map { $0.reversed() }.reversed()
    }
}

extension String {
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#endif
    }
}


func scrollToBottom(proxy: ScrollViewProxy, id: String = "bottomID", anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
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
//       action()
   }
}
