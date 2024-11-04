//
//  EnvironmentKeys.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/11/2024.
//

import SwiftUI

private struct IsQuickKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct ProviderKey: EnvironmentKey {
    static let defaultValue: [Provider] = []
}

private struct IsSearchKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

#if os(macOS)
private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}
#endif


extension EnvironmentValues {
    var isSearch: Bool {
        get { self[IsSearchKey.self] }
        set { self[IsSearchKey.self] = newValue }
    }
    
    var providers: [Provider] {
        get { self[ProviderKey.self] }
        set { self[ProviderKey.self] = newValue }
    }
    
    var isQuick: Bool {
        get { self[IsQuickKey.self] }
        set { self[IsQuickKey.self] = newValue }
    }
    
    #if os(macOS)
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
    #endif
}
