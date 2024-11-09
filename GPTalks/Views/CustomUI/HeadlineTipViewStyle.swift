//
//  HeadlineTipViewStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/11/2024.
//

import TipKit

struct HeadlineTipViewStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyle.Configuration) -> some View {
        VStack {
            HStack {
                configuration.image
                
                VStack(alignment: .leading) {
                    configuration.title
                        .font(.headline)
                    
                    configuration.message
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: { configuration.tip.invalidate(reason: .tipClosed) }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                    
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            ForEach(configuration.actions) { action in
                Button(action: action.handler) {
                    action.label().foregroundStyle(.blue)
                }
            }
        }
        .padding()
    }
}

struct TopividerTipViewStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyle.Configuration) -> some View {
//        VStack {
            Spacer()
            Divider()
            configuration.title
                .font(.headline)
//        }
    }
}

#Preview {
    VStack {
        TipView(SwipeActionTip())
            .tipViewStyle(HeadlineTipViewStyle())
    }
    .frame(width: 300, height: 300)
    .padding()
}
