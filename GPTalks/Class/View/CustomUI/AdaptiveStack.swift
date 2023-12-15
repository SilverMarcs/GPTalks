//
//  AdaptiveStack.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/12/2023.
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
   let isHorizontal: Bool
   let content: Content

   init(isHorizontal: Bool, @ViewBuilder content: () -> Content) {
       self.isHorizontal = isHorizontal
       self.content = content()
   }

   var body: some View {
       Group {
           if isHorizontal {
               HStack(spacing: 10) {
                  content
               }
           } else {
               VStack(alignment: .leading, spacing: 10) {
                  content
               }
           }
       }
   }
}
