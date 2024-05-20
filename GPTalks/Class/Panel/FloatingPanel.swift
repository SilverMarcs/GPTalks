//
//  FloatingPanel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/05/2024.
//

#if os(macOS)
import SwiftUI
import AppKit
import KeyboardShortcuts


class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(view: @escaping () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .closable, .fullSizeContentView, .titled],
                   backing: backing,
                   defer: flag)
        
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenDisallowsTiling)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        animationBehavior = .none
        
//        isOpaque = false
//        backgroundColor = .clear
        
        let hostingView = NSHostingView(rootView: view()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self)
        )
        
        let visualEffectView = NSVisualEffectView(frame: contentRect)
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        
        visualEffectView.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])
        
        contentView = visualEffectView
    }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
     
    override func close() {
        super.close()
        isPresented = false
    }
     
    override var canBecomeKey: Bool {
        return true
    }
     
    override var canBecomeMain: Bool {
        return true
    }
}

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}
 
extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

fileprivate struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 600, height: 20)
    @ViewBuilder let view: () -> PanelContent
    @State var panel: FloatingPanel<PanelContent>?
 
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanel(view: view, contentRect: contentRect, isPresented: $isPresented)
                panel?.center()
                if isPresented {
                    present()
                }
            }.onDisappear {
                panel?.close()
                panel = nil
            }.onChange(of: isPresented) { newValue in
                if newValue {
                    present()
                } else {
                    panel?.close()
                }
            }
    }
 
    func present() {
        panel?.orderFront(nil)
        panel?.makeKey()
    }
}

extension View {
    func floatingPanel<Content: View>(isPresented: Binding<Bool>,
                                      contentRect: CGRect = CGRect(x: 0, y: 0, width: 600, height: 20),
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, contentRect: contentRect, view: content))
    }
}
extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}

#endif
