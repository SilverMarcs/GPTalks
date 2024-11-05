//
//  EnvironmentKeys.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/11/2024.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var isSearch: Bool = false

    @Entry var providers: [Provider] = []
    
    @Entry var isQuick: Bool = false

    #if os(macOS)
    @Entry var floatingPanel: NSPanel? = nil
    #endif
}

