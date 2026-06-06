import SwiftUI
import AppKit

struct GrammarTextView: NSViewRepresentable {
    @Binding var text: String
    let mistakes: [GrammarMistake]
    let onMistakeTapped: (GrammarMistake, NSRect) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let tv = scrollView.documentView as! NSTextView
        tv.delegate = context.coordinator
        tv.isEditable = true
        tv.isRichText = false
        tv.font = NSFont.systemFont(ofSize: 13)
        tv.textContainerInset = NSSize(width: 8, height: 8)
        tv.backgroundColor = NSColor.textBackgroundColor
        tv.drawsBackground = true
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isAutomaticQuoteSubstitutionEnabled = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let click = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
        tv.addGestureRecognizer(click)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        let tv = scrollView.documentView as! NSTextView

        tv.delegate = nil

        if tv.string != text {
            tv.string = text
        }

        let storage = tv.textStorage!
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.removeAttribute(.underlineStyle, range: fullRange)
        storage.removeAttribute(.underlineColor, range: fullRange)
        storage.addAttribute(.font, value: NSFont.systemFont(ofSize: 13), range: fullRange)
        for mistake in mistakes {
            guard let range = mistake.range,
                  range.location != NSNotFound,
                  range.location + range.length <= storage.length else { continue }
            storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            storage.addAttribute(.underlineColor, value: NSColor.systemRed, range: range)
        }

        tv.delegate = context.coordinator
        context.coordinator.mistakes = mistakes
        context.coordinator.onMistakeTapped = onMistakeTapped
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GrammarTextView
        var mistakes: [GrammarMistake] = []
        var onMistakeTapped: ((GrammarMistake, NSRect) -> Void)?

        init(_ parent: GrammarTextView) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            if let tv = notification.object as? NSTextView {
                print("[GrammarTextView] text changed, length:", tv.string.count)
                parent.text = tv.string
            }
        }

        @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
            guard let tv = gesture.view as? NSTextView,
                  let layoutManager = tv.layoutManager,
                  let textContainer = tv.textContainer else { return }

            let point = gesture.location(in: tv)
            let charIndex = layoutManager.characterIndex(
                for: point,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )

            for mistake in mistakes {
                guard let range = mistake.range, range.location != NSNotFound else { continue }
                guard charIndex >= range.location && charIndex < range.location + range.length else { continue }

                let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                rect.origin.x += tv.textContainerOrigin.x
                rect.origin.y += tv.textContainerOrigin.y
                let rectInWindow = tv.convert(rect, to: nil)
                let screenRect = tv.window?.convertToScreen(rectInWindow) ?? rectInWindow
                onMistakeTapped?(mistake, screenRect)
                break
            }
        }
    }
}
