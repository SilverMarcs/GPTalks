//
//  CustomSearchField.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

extension NSSearchField {
    open override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsets(top: -1, left: -2, bottom: 0, right: -2)
    }
    
    // focus ring to none
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
