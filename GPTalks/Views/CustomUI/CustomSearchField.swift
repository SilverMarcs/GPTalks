//
//  SessionSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

#if os(macOS)
import SwiftUI

extension NSSearchField {
    open override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsets(top: -1, left: -2, bottom: -1, right: -2)
    }
    
    // focus ring to none
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
#endif
