import SwiftUI
import AppKit
import CoreGraphics

private let panelPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

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
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                TextEditor(text: $inputText)
                    .font(.body)
                    .padding(6)
                    .scrollContentBackground(.hidden)
            }
            .frame(height: 120)
            .padding([.horizontal, .top], 12)

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
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)

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
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
            }

            // Result
            ScrollView {
                Text(resultText.isEmpty ? "Result will appear here…" : resultText)
                    .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Bottom toolbar
            Divider()
            HStack(spacing: 8) {
                Button("Improve") {
                    runImprove()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .background(isLoading || inputText.isEmpty ? panelPurple.opacity(0.4) : panelPurple)
                .foregroundStyle(.white)
                .cornerRadius(5)
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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .onAppear {
            inputText = initialText
        }
    }

    private func pill(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12))
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(isSelected ? panelPurple : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(
                    isSelected ? panelPurple : Color(NSColor.separatorColor),
                    lineWidth: 1
                ))
                .foregroundStyle(isSelected ? Color.white : Color(NSColor.secondaryLabelColor))
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
