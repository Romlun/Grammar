import AppKit
import SwiftUI

class PanelService: ObservableObject {
    static let shared = PanelService()

    @Published var panel: NSPanel?

    private init() {}

    func show(withText text: String) {
        if panel == nil {
            let p = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 380),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            p.level = .floating
            p.isFloatingPanel = true
            p.titlebarAppearsTransparent = true
            panel = p
        }

        panel?.contentView = NSHostingView(rootView: FloatingPanelView(initialText: text))
        panel?.center()
        panel?.makeKeyAndOrderFront(nil)
    }
}
