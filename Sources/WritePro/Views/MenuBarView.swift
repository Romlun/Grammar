#if os(macOS)
import SwiftUI
import AppKit

struct MenuBarView: View {
    var body: some View {
        Button("Open WritePro") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }

        Divider()

        Text("Shortcut: ⌘⇧W")
            .disabled(true)

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}

#endif
