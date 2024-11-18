//
//  QuickPanelWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

#if os(macOS)
import SwiftUI
import SwiftData
import KeyboardShortcuts

class QuickPanelWindow: NSPanel {
    private var heightConstraint: NSLayoutConstraint?
    var chatVM: ChatVM
    
    @discardableResult
    init(
         contentRect: NSRect = NSRect(x: 0, y: 0, width: 650, height: 57),
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         chatVM: ChatVM,
         modelContext: ModelContext
    ) {
        self.chatVM = chatVM
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
        
        let statusId = ChatStatus.quick.id
        var descriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.statusId == statusId }
        )
        descriptor.fetchLimit = 1
        
        let quickChat = try! modelContext.fetch(descriptor)
        let chat = quickChat.first!
        
        let hostingView = NSHostingView(rootView: QuickPanelView(
            chat: chat,
            updateHeight: { [weak self] newHeight in self?.updateHeight(to: newHeight) },
            toggleVisibility: { [weak self] in self?.toggleVisibility() }
        )
        .ignoresSafeArea()
        .environment(\.isQuick, true)
        .environment(chatVM)
        .modelContainer(modelContext.container)
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
        
        KeyboardShortcuts.onKeyDown(for: .togglePanel) { [weak self] in
            self?.toggleVisibility()
        }
        
        self.center()
    }
    
    func toggleVisibility() {
        if chatVM.isQuickPanelPresented {
            chatVM.isQuickPanelPresented = false
            close()
        } else {
            chatVM.isQuickPanelPresented = true
            makeKeyAndOrderFront(nil)
        }
    }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func close() {
        chatVM.isQuickPanelPresented = false
        super.close()
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
#endif
