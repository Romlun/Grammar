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
        tv.isAutomaticDashSubstitutionEnabled = false
        tv.isAutomaticQuoteSubstitutionEnabled = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        let click = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleClick(_:))
        )
        tv.addGestureRecognizer(click)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let tv = scrollView.documentView as! NSTextView
        context.coordinator.binding = $text
        context.coordinator.onMistakeTapped = onMistakeTapped

        context.coordinator.isApplyingAttributes = true
        if tv.string != text { tv.string = text }
        applyUnderlines(to: tv, mistakes: mistakes)
        context.coordinator.mistakes = mistakes
        context.coordinator.isApplyingAttributes = false
    }

    private func applyUnderlines(to tv: NSTextView, mistakes: [GrammarMistake]) {
        guard let storage = tv.textStorage else { return }
        let fullRange = NSRange(location: 0, length: storage.length)
        storage.beginEditing()
        storage.removeAttribute(.underlineStyle, range: fullRange)
        storage.removeAttribute(.underlineColor, range: fullRange)
        storage.addAttribute(
            .font,
            value: NSFont.systemFont(ofSize: 13),
            range: fullRange
        )
        for mistake in mistakes {
            guard let range = mistake.range,
                  range.location != NSNotFound,
                  range.location + range.length <= storage.length else { continue }
            storage.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
            storage.addAttribute(
                .underlineColor,
                value: NSColor.systemRed,
                range: range
            )
        }
        storage.endEditing()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var binding: Binding<String>
        var mistakes: [GrammarMistake] = []
        var onMistakeTapped: ((GrammarMistake, NSRect) -> Void)?
        var isApplyingAttributes = false

        init(binding: Binding<String>) {
            self.binding = binding
        }

        func textDidChange(_ notification: Notification) {
            guard !isApplyingAttributes,
                  let tv = notification.object as? NSTextView else { return }
            print("[GrammarTextView] textDidChange, length:", tv.string.count)
            DispatchQueue.main.async {
                self.binding.wrappedValue = tv.string
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
                guard let range = mistake.range,
                      range.location != NSNotFound,
                      charIndex >= range.location,
                      charIndex < range.location + range.length else { continue }
                let glyphRange = layoutManager.glyphRange(
                    forCharacterRange: range,
                    actualCharacterRange: nil
                )
                var rect = layoutManager.boundingRect(
                    forGlyphRange: glyphRange,
                    in: textContainer
                )
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
