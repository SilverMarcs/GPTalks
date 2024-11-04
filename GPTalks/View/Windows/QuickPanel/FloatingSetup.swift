//
//  FloatingSetup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

#if os(macOS)
import SwiftUI

class QuickPanelWindow2<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    private var heightConstraint: NSLayoutConstraint?
    
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
        toolbar?.isVisible = false
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        animationBehavior = .none
        
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
        
        // Set the initial height constraint
        heightConstraint = visualEffectView.heightAnchor.constraint(equalToConstant: contentRect.height)
        heightConstraint?.isActive = true
        self.contentMinSize = NSSize(width: contentRect.width, height: contentRect.height)
        self.contentMaxSize = NSSize(width: contentRect.width, height: 500)
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
    
    func updateHeight(to height: CGFloat) {
        guard let screenFrame = screen?.visibleFrame else { return }
        let currentFrame = frame
        let newFrame = NSRect(x: currentFrame.origin.x,
                              y: currentFrame.origin.y + (currentFrame.height - height),
                              width: currentFrame.width,
                              height: height)
        
        // Ensure the new frame is within the screen bounds
        let adjustedFrame = NSIntersectionRect(newFrame, screenFrame)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            self.animator().setFrame(adjustedFrame, display: true)
            self.contentView?.animator().setFrameSize(NSSize(width: adjustedFrame.width, height: height))
            
            heightConstraint?.animator().constant = height
        }
        
        self.contentMinSize.height = height
        self.contentMaxSize.height = height
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
    @Binding var showAdditionalContent: Bool
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 650, height: 57)
    @ViewBuilder let view: () -> PanelContent
    @State var panel: QuickPanelWindow2<PanelContent>?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = QuickPanelWindow2(view: view, contentRect: contentRect, isPresented: $isPresented)
                panel?.center()
                if isPresented {
                    present()
                }
            }.onDisappear {
                panel?.close()
                panel = nil
            }.onChange(of: isPresented) {
                if isPresented {
                    present()
                } else {
                    panel?.close()
                }
            }.onChange(of: showAdditionalContent) {
                if showAdditionalContent {
                    panel?.updateHeight(to: 500)
                } else {
                    panel?.updateHeight(to: contentRect.height)
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
                                      showAdditionalContent: Binding<Bool>,
                                      contentRect: CGRect = CGRect(x: 0, y: 0, width: 650, height: 57),
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, showAdditionalContent: showAdditionalContent, contentRect: contentRect, view: content))
    }
}

#endif
