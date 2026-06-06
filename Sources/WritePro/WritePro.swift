import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        ShortcutService.shared.register()
    }
}

@main
struct WritePro: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 450)
        }

        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "pencil.circle.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}
