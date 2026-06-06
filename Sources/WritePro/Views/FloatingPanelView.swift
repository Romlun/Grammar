import SwiftUI
import AppKit
import CoreGraphics

private let panelPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

struct FloatingPanelView: View {
    let initialText: String

    @State private var inputText: String = ""
    @State private var selectedAction: Action = .quickPolish
    @State private var selectedStyle: StyleContext = .everyday
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

            // Action picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Action.allCases) { action in
                        Button {
                            selectedAction = action
                        } label: {
                            Text(action.label)
                                .font(.system(size: 12))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(selectedAction == action ? panelPurple : Color.clear)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(
                                    selectedAction == action ? panelPurple : Color(NSColor.separatorColor),
                                    lineWidth: 1
                                ))
                                .foregroundStyle(selectedAction == action ? Color.white : Color(NSColor.secondaryLabelColor))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)

            // Style picker
            HStack {
                Picker("Style", selection: $selectedStyle) {
                    ForEach(StyleContext.allCases) { style in
                        Text(style.label).tag(style)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

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

    private func runImprove() {
        Task {
            isLoading = true
            resultText = ""
            let (system, user) = PromptBuilder.build(action: selectedAction, style: selectedStyle, input: inputText)
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
