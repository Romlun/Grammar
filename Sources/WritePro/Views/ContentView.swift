import SwiftUI

private let purple       = Color(red: 124/255, green: 58/255,  blue: 237/255)
private let sidebarBg   = Color(red: 30/255,  green: 30/255,  blue: 30/255)
private let unselected  = Color(red: 153/255, green: 153/255, blue: 153/255)
private let sectionLbl  = Color(red: 85/255,  green: 85/255,  blue: 85/255)

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selection: SidebarSelection = .context(.everyday)
    @State private var selectedTone: ToneModifier? = nil
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSettings: Bool = false

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
                Button {
                    grammarEnabled.toggle()
                    UserDefaults.standard.set(grammarEnabled, forKey: "grammarEnabled")
                    if !grammarEnabled { mistakes = [] }
                } label: {
                    Image(systemName: grammarEnabled ? "text.badge.checkmark" : "text.badge.xmark")
                        .foregroundStyle(grammarEnabled ? purple : Color(NSColor.secondaryLabelColor))
                }
                .help(grammarEnabled ? "Grammar check on" : "Grammar check off")
            }
            ToolbarItem(placement: .automatic) {
                Button { showSettings = true } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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

            Color.clear.frame(height: 12)

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
        .background(sidebarBg)
    }

    private func sidebarSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(sectionLbl)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 4)
            content()
        }
    }

    private func sidebarButton(icon: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 16, alignment: .center)
                Text(label)
                    .font(.system(size: 12))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? purple : Color.clear)
            .cornerRadius(6)
            .foregroundStyle(isSelected ? Color.white : unselected)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
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
                        .padding(.trailing, 10)
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
                        .padding(16)
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
            VStack(alignment: .leading, spacing: 4) {
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
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy subject")
                    }
                    .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(NSColor.secondaryLabelColor))
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                Text(email.body)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            resultButtons(copyText: email.body, useAsInput: email.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resultButtons(copyText: String, useAsInput: String) -> some View {
        HStack(spacing: 8) {
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
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Bottom toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 8) {
            if showTonePills {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ToneModifier.allCases) { tone in
                            Button {
                                selectedTone = selectedTone == tone ? nil : tone
                            } label: {
                                Text(tone.label)
                                    .font(.system(size: 11))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(selectedTone == tone ? purple.opacity(0.15) : Color.clear)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(
                                        selectedTone == tone ? purple : Color(NSColor.separatorColor),
                                        lineWidth: 1
                                    ))
                                    .foregroundStyle(selectedTone == tone ? purple : Color(NSColor.secondaryLabelColor))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
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
            .font(.system(size: 13, weight: .medium))
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(isLoading || inputText.isEmpty ? purple.opacity(0.4) : purple)
            .foregroundStyle(.white)
            .cornerRadius(6)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
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
