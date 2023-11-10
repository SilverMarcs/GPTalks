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

extension Date {
    /// SwifterSwift: User’s current calendar.
    var calendar: Calendar { Calendar.current }
    
    /// SwifterSwift: Check if date is within today.
    ///
    ///     Date().isInToday -> true
    ///
    var isInToday: Bool {
        return calendar.isDateInToday(self)
    }

    /// SwifterSwift: Check if date is within yesterday.
    ///
    ///     Date().isInYesterday -> false
    ///
    var isInYesterday: Bool {
        return calendar.isDateInYesterday(self)
    }
    
    /// SwifterSwift: Date string from date.
    ///
    ///     Date().dateString(ofStyle: .short) -> "1/12/17"
    ///     Date().dateString(ofStyle: .medium) -> "Jan 12, 2017"
    ///     Date().dateString(ofStyle: .long) -> "January 12, 2017"
    ///     Date().dateString(ofStyle: .full) -> "Thursday, January 12, 2017"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: date string.
    func dateString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Date and time string from date.
    ///
    ///     Date().dateTimeString(ofStyle: .short) -> "1/12/17, 7:32 PM"
    ///     Date().dateTimeString(ofStyle: .medium) -> "Jan 12, 2017, 7:32:00 PM"
    ///     Date().dateTimeString(ofStyle: .long) -> "January 12, 2017 at 7:32:00 PM GMT+3"
    ///     Date().dateTimeString(ofStyle: .full) -> "Thursday, January 12, 2017 at 7:32:00 PM GMT+03:00"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: date and time string.
    func dateTimeString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = style
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    var iMessageDateTimeString: String {
        if isInToday {
            return String(localized: "Today") + " " + timeString(ofStyle: .short)
        } else if isInYesterday {
            return String(localized: "Yesterday") + " " + timeString(ofStyle: .short)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    /// SwifterSwift: Time string from date
    ///
    ///     Date().timeString(ofStyle: .short) -> "7:37 PM"
    ///     Date().timeString(ofStyle: .medium) -> "7:37:02 PM"
    ///     Date().timeString(ofStyle: .long) -> "7:37:02 PM GMT+3"
    ///     Date().timeString(ofStyle: .full) -> "7:37:02 PM GMT+03:00"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: time string.
    func timeString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = style
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }
    
    
}
