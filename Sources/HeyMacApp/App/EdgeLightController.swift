import AppKit
import SwiftUI

@MainActor
final class EdgeLightController {
    static let shared = EdgeLightController()
    private var window: NSPanel?
    private let elevated = LockScreenSpace()

    func show() {
        if window == nil {
            let panel = NSPanel(
                contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered, defer: false
            )
            panel.isFloatingPanel = true
            panel.level = NSWindow.Level(Int(CGShieldingWindowLevel()) + 1)
            panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            panel.isReleasedWhenClosed = false
            
            let view = NSHostingView(rootView: EdgeLightView())
            panel.contentView = view
            self.window = panel
        }
        
        guard let window = self.window else { return }
        window.setFrame(NSScreen.main?.frame ?? window.frame, display: true)
        
        elevated?.show(window)
        
        window.alphaValue = 0
        window.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            window.animator().alphaValue = 1.0
        }
    }

    func hide() {
        guard let window = self.window else { return }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            self.elevated?.hide(window)
            window.orderOut(nil)
        })
    }
}

struct EdgeLightView: View {
    var body: some View {
        Rectangle()
            .stroke(Color.white, lineWidth: 80)
            .edgesIgnoringSafeArea(.all)
    }
}
