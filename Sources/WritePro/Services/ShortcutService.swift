import Carbon.HIToolbox
import AppKit
import CoreGraphics

final class ShortcutService {
    static let shared = ShortcutService()
    private var hotKeyRef: EventHotKeyRef?

    private init() {}

    func register() {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 0x57525450  // 'WRTP'
        hotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                ShortcutService.shared.hotKeyFired()
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        RegisterEventHotKey(
            UInt32(kVK_ANSI_W),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func hotKeyFired() {
        let trusted = AXIsProcessTrusted()
        guard trusted else {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)
            return
        }

        // Cmd+C to copy selected text
        simulateKeyEvent(keyCode: CGKeyCode(kVK_ANSI_C), flags: .maskCommand)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let text = NSPasteboard.general.string(forType: .string) ?? ""
            PanelService.shared.show(withText: text)
        }
    }

    func simulateKeyEvent(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let down = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let up   = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        down?.flags = flags
        up?.flags   = flags
        down?.post(tap: .cgSessionEventTap)
        up?.post(tap: .cgSessionEventTap)
    }
}
