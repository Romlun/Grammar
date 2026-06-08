#if os(macOS)
import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selection: SidebarSelection = .context(.everyday)
    @State private var selectedTone: ToneModifier? = nil
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSettings: Bool = false
    @State private var showHistory: Bool = false

    // Grammar check
    @State private var grammarEnabled: Bool = UserDefaults.standard.bool(forKey: "grammarEnabled")
    @State private var mistakes: [GrammarMistake] = []
    @State private var activeMistake: GrammarMistake? = nil
    @State private var mistakePopoverWindow: NSWindow? = nil
    @State private var grammarTimer: Timer? = nil

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    editorPanel
                    Divider()
                    resultPanel
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomToolbar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button { showHistory = true } label: {
                    Image(systemName: "clock")
                }
                .help("History")
                .accessibilityLabel("History")
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    grammarEnabled.toggle()
                    UserDefaults.standard.set(grammarEnabled, forKey: "grammarEnabled")
                    if !grammarEnabled { mistakes = [] }
                } label: {
                    Image(systemName: grammarEnabled ? "text.badge.checkmark" : "text.badge.xmark")
                        .foregroundStyle(grammarEnabled ? DesignTokens.accent : Color(NSColor.secondaryLabelColor))
                }
                .help(grammarEnabled ? "Grammar check on" : "Grammar check off")
                .accessibilityLabel("Grammar Check")
            }
            ToolbarItem(placement: .automatic) {
                Button { showSettings = true } label: {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showHistory) {
            HistoryViewMacOS(onSelect: { entry in
                inputText = entry.original
                resultText = entry.result
            })
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            sidebarSection(label: "CONTEXT") {
                ForEach(StyleContext.allCases) { style in
                    sidebarButton(
                        icon: style.icon,
                        label: style.label,
                        isSelected: selection == .context(style)
                    ) {
                        selection = .context(style)
                    }
                }
            }

            Color.clear.frame(height: DesignTokens.sp3)

            sidebarSection(label: "TOOLS") {
                ForEach(Tool.allCases) { tool in
                    sidebarButton(
                        icon: tool.icon,
                        label: tool.label,
                        isSelected: selection == .tool(tool)
                    ) {
                        selection = .tool(tool)
                        selectedTone = nil
                    }
                }
            }

            Spacer()
        }
        .frame(width: 180)
        .background(DesignTokens.sidebarBackground)
    }

    private func sidebarSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(DesignTokens.sidebarSectionLabel)
                .padding(.horizontal, DesignTokens.sp3)
                .padding(.top, DesignTokens.sp4)
                .padding(.bottom, DesignTokens.sp1)
            content()
        }
    }

    private func sidebarButton(icon: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.sp2) {
                Image(systemName: icon)
                    .frame(width: 16, alignment: .center)
                Text(label)
                    .font(.system(size: 13))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, DesignTokens.sp3)
            .padding(.vertical, DesignTokens.sp2)
            .background(
                (isSelected ? DesignTokens.accent : Color.clear)
                    .animation(.easeInOut(duration: 0.12), value: isSelected)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusCard))
            .foregroundStyle(isSelected ? Color.white : DesignTokens.sidebarItemUnselected)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.sp2)
    }

    // MARK: - Helpers

    private var showTonePills: Bool {
        if case .context = selection { return true }
        return selection == .tool(.emailPolish)
    }

    private var emailComponents: (subject: String, body: String)? {
        guard selection == .tool(.emailPolish),
              resultText.hasPrefix("SUBJECT:") else { return nil }
        let lines = resultText.components(separatedBy: "\n")
        let subject = lines.first?
            .replacingOccurrences(of: "SUBJECT:", with: "")
            .trimmingCharacters(in: .whitespaces) ?? ""
        let body = lines.dropFirst().joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (subject, body)
    }

    // MARK: - Editor panel

    private var editorPanel: some View {
        VStack(spacing: 0) {
            GrammarTextView(
                text: $inputText,
                mistakes: grammarEnabled ? mistakes : [],
                onMistakeTapped: { mistake, rect in
                    activeMistake = mistake
                    showMistakePopover(for: mistake, at: rect)
                }
            )
            .onChange(of: inputText) { _, newValue in
                guard grammarEnabled else { return }
                grammarTimer?.invalidate()
                grammarTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    Task { await checkGrammar(text: newValue) }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !inputText.isEmpty {
                HStack {
                    Spacer()
                    Text("\(inputText.split(separator: " ").count) words")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(NSColor.tertiaryLabelColor))
                        .padding(.trailing, DesignTokens.sp3)
                        .padding(.bottom, 6)
                }
                .background(Color(NSColor.textBackgroundColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Result panel

    private var resultPanel: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let email = emailComponents {
                emailResultPanel(email: email)
            } else {
                ScrollView {
                    Text(resultText.isEmpty ? "Your improved text will appear here" : resultText)
                        .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignTokens.sp4)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !resultText.isEmpty {
                    resultButtons(copyText: resultText, useAsInput: resultText)
                }
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emailResultPanel(email: (subject: String, body: String)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: DesignTokens.sp1) {
                Text("Subject")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(NSColor.secondaryLabelColor))
                Text(email.subject)
                    .font(.system(size: 13, weight: .medium))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(email.subject, forType: .string)
                } label: {
                    HStack(spacing: DesignTokens.sp1) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy subject")
                    }
                    .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(NSColor.secondaryLabelColor))
            }
            .padding(DesignTokens.sp3)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                Text(email.body)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignTokens.sp3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            resultButtons(copyText: email.body, useAsInput: email.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resultButtons(copyText: String, useAsInput: String) -> some View {
        HStack(spacing: DesignTokens.sp2) {
            Button {
                runImprove()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(NSColor.secondaryLabelColor))

            Spacer()

            Button {
                inputText = useAsInput
                resultText = ""
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.uturn.left")
                    Text("Use as Input")
                }
                .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(NSColor.secondaryLabelColor))

            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(copyText, forType: .string)
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
                .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(NSColor.secondaryLabelColor))
        }
        .padding(.horizontal, DesignTokens.sp3)
        .padding(.bottom, DesignTokens.sp2)
    }

    // MARK: - Bottom toolbar

    private var bottomToolbar: some View {
        HStack(spacing: DesignTokens.sp2) {
            if showTonePills {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ToneModifier.allCases) { tone in
                            Button {
                                selectedTone = selectedTone == tone ? nil : tone
                            } label: {
                                Text(tone.label)
                                    .font(.system(size: 11))
                                    .padding(.vertical, DesignTokens.sp1)
                                    .padding(.horizontal, 10)
                                    .background(
                                        (selectedTone == tone ? DesignTokens.accentSubtle : Color.clear)
                                            .animation(.easeInOut(duration: 0.10), value: selectedTone == tone)
                                    )
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(
                                        selectedTone == tone ? DesignTokens.accent : Color(NSColor.separatorColor),
                                        lineWidth: 1
                                    ))
                                    .foregroundStyle(selectedTone == tone ? DesignTokens.accent : Color(NSColor.secondaryLabelColor))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignTokens.sp1)
                }
            } else {
                Spacer()
            }

            Button("Improve ↵") {
                runImprove()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(isLoading || inputText.isEmpty)
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, DesignTokens.sp4)
            .background(isLoading || inputText.isEmpty ? DesignTokens.accentDisabled : DesignTokens.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusCard))
        }
        .padding(.horizontal, DesignTokens.sp3)
        .frame(height: 48)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1)
        }
    }

    // MARK: - Improve

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
            if !resultText.isEmpty && !resultText.hasPrefix("Error:") {
                HistoryService.shared.add(
                    mode: selection.label,
                    original: inputText,
                    result: resultText
                )
            }
        }
    }

    // MARK: - Grammar check

    func checkGrammar(text: String) async {
        guard let apiKey = KeychainService.load(), !apiKey.isEmpty else { return }
        var results = await GrammarCheckService.shared.run(text: text, apiKey: apiKey)
        for i in results.indices {
            if let range = text.range(of: results[i].phrase) {
                results[i].range = NSRange(range, in: text)
            }
        }
        await MainActor.run { mistakes = results }
    }

    func showMistakePopover(for mistake: GrammarMistake, at rect: NSRect) {
        mistakePopoverWindow?.close()
        let popover = NSWindow(
            contentRect: NSRect(x: rect.minX, y: rect.minY - 160, width: 280, height: 160),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        popover.title = ""
        popover.titlebarAppearsTransparent = true
        popover.level = .floating
        popover.isReleasedWhenClosed = false
        popover.contentView = NSHostingView(rootView: MistakePopoverView(
            mistake: mistake,
            onApply: {
                inputText = (inputText as NSString).replacingCharacters(
                    in: mistake.range ?? NSRange(),
                    with: mistake.suggestion
                )
                popover.close()
                mistakePopoverWindow = nil
            },
            onDismiss: {
                popover.close()
                mistakePopoverWindow = nil
            }
        ))
        popover.makeKeyAndOrderFront(nil)
        mistakePopoverWindow = popover
    }
}

#endif
