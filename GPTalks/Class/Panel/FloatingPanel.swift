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
                   styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
                   backing: backing,
                   defer: flag)
        
        isFloatingPanel = true
        level = .floating
        collectionBehavior.insert(.fullScreenAuxiliary)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        animationBehavior = .utilityWindow
        
        let hostingView = NSHostingView(rootView: view()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self))
        
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
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 20)
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
                                      contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 20),
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, contentRect: contentRect, view: content))
    }
}

//struct VisualEffectView: NSViewRepresentable {
//    var material: NSVisualEffectView.Material
//    var blendingMode: NSVisualEffectView.BlendingMode
//    var state: NSVisualEffectView.State
//    var emphasized: Bool
// 
//    func makeNSView(context: Context) -> NSVisualEffectView {
//        context.coordinator.visualEffectView
//    }
// 
//    func updateNSView(_ view: NSVisualEffectView, context: Context) {
//        context.coordinator.update(
//            material: material,
//            blendingMode: blendingMode,
//            state: state,
//            emphasized: emphasized
//        )
//    }
// 
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
// 
//    class Coordinator {
//        let visualEffectView = NSVisualEffectView()
// 
//        init() {
//            visualEffectView.blendingMode = .withinWindow
//        }
// 
//        func update(material: NSVisualEffectView.Material,
//                        blendingMode: NSVisualEffectView.BlendingMode,
//                        state: NSVisualEffectView.State,
//                        emphasized: Bool) {
//            visualEffectView.material = material
//        }
//    }
//}

class MaterialBackgroundView: NSVisualEffectView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.material = .hudWindow
        self.blendingMode = .behindWindow
        self.state = .active
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}

#endif
