//
//  Extnsions.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import Foundation
import SwiftUIX
import Kingfisher
import Combine

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

extension KFCrossPlatformImage {
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.image = self
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([self])
#endif
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}


extension Date {
    
    var dialogueDesc: String {
        if self.isInYesterday {
            return String(localized: "Yesterday")
        }
        if self.isInToday {
            return timeString(ofStyle: .short)
        }
        return dateString(ofStyle: .short)
    }
}

extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        // Any better ideas on how to get the didSet semantics?
        // This works, but I'm not sure if it's ideal.
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
