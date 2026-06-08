#if os(macOS)
import SwiftUI
import AppKit
import CoreGraphics

struct FloatingPanelView: View {
    let initialText: String

    @State private var inputText: String = ""
    @State private var selection: SidebarSelection = .context(.everyday)
    @State private var selectedTone: ToneModifier? = nil
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Input
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: DesignTokens.radiusCard)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                TextEditor(text: $inputText)
                    .font(.body)
                    .padding(6)
                    .scrollContentBackground(.hidden)
            }
            .frame(height: 120)
            .padding([.horizontal, .top], DesignTokens.sp3)

            // Context picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(StyleContext.allCases) { style in
                        pill(label: style.label, isSelected: selection == .context(style)) {
                            selection = .context(style)
                        }
                    }
                    Divider().frame(height: 20)
                    ForEach(Tool.allCases) { tool in
                        pill(label: tool.label, isSelected: selection == .tool(tool)) {
                            selection = .tool(tool)
                            selectedTone = nil
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.sp1)
            }
            .padding(.horizontal, DesignTokens.sp3)
            .padding(.top, DesignTokens.sp2)

            // Tone picker (context mode only)
            if case .context = selection {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ToneModifier.allCases) { tone in
                            pill(label: tone.label, isSelected: selectedTone == tone) {
                                selectedTone = selectedTone == tone ? nil : tone
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.sp1)
                }
                .padding(.horizontal, DesignTokens.sp3)
                .padding(.top, 6)
            }

            // Result
            ScrollView {
                Text(resultText.isEmpty ? "Result will appear here…" : resultText)
                    .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignTokens.sp2)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, DesignTokens.sp3)
            .padding(.top, DesignTokens.sp2)

            // Bottom toolbar
            Divider()
            HStack(spacing: DesignTokens.sp2) {
                Button("Improve") {
                    runImprove()
                }
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .semibold))
                .padding(.vertical, 5)
                .padding(.horizontal, DesignTokens.sp3)
                .background(isLoading || inputText.isEmpty ? DesignTokens.accentDisabled : DesignTokens.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusCard))
                .disabled(isLoading || inputText.isEmpty)

                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(resultText, forType: .string)
                }
                .disabled(resultText.isEmpty)

                Button("Replace") {
                    replace()
                }
                .disabled(resultText.isEmpty)

                Spacer()

                if isLoading {
                    ProgressView().scaleEffect(0.7)
                }
            }
            .padding(.horizontal, DesignTokens.sp3)
            .padding(.vertical, DesignTokens.sp2)
        }
        .onAppear {
            inputText = initialText
        }
    }

    private func pill(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12))
                .padding(.vertical, DesignTokens.sp1)
                .padding(.horizontal, 10)
                .background(
                    (isSelected ? DesignTokens.accentSubtle : Color.clear)
                        .animation(.easeInOut(duration: 0.10), value: isSelected)
                )
                .clipShape(Capsule())
                .overlay(Capsule().stroke(
                    isSelected ? DesignTokens.accent : Color(NSColor.separatorColor),
                    lineWidth: 1
                ))
                .foregroundStyle(isSelected ? DesignTokens.accent : Color(NSColor.secondaryLabelColor))
        }
        .buttonStyle(.plain)
    }

    private func runImprove() {
        Task {
            isLoading = true
            resultText = ""
            let (system, user) = PromptBuilder.build(selection: selection, tone: selectedTone, input: inputText)
            do {
                for try await chunk in ClaudeService.stream(prompt: user, system: system) {
                    resultText += chunk
                }
            } catch {
                resultText = "Error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    private func replace() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        NSApp.windows.filter { $0 is NSPanel }.forEach { $0.close() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ShortcutService.shared.simulateKeyEvent(keyCode: 0x09, flags: .maskCommand)
        }
    }
}

#endif
