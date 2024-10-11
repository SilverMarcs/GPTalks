//
//  ImageUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
import PhotosUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }

    init?(data: Data) {
        guard let platformImage = PlatformImage.from(data: data) else {
            return nil
        }
        self.init(platformImage: platformImage)
    }
}

extension PlatformImage {
    static func from(data: Data) -> PlatformImage? {
        #if os(macOS)
        return NSImage(data: data)
        #else
        return UIImage(data: data)
        #endif
    }
}
