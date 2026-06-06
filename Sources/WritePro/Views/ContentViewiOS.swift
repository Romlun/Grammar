#if os(iOS)
import SwiftUI

private let appPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

extension SidebarSelection {
    var icon: String {
        switch self {
        case .context(let c): return c.icon
        case .tool(let t):    return t.icon
        }
    }
    var label: String {
        switch self {
        case .context(let c): return c.label
        case .tool(let t):    return t.label
        }
    }
}

struct ContentViewiOS: View {
    @State private var inputText        = ""
    @State private var selection: SidebarSelection = .context(.everyday)
    @State private var selectedTone: ToneModifier? = nil
    @State private var resultText       = ""
    @State private var isLoading        = false
    @State private var showSelection    = false
    @State private var showSettings     = false
    @State private var showHistory      = false
    @FocusState private var editorFocused: Bool
    @Environment(\.colorScheme) private var scheme

    private var titleColor: Color {
        scheme == .dark
            ? Color(red: 167/255, green: 139/255, blue: 250/255)
            : Color(red: 76/255, green: 29/255, blue: 149/255)
    }
    private var resultCardBg: Color { appPurple.opacity(scheme == .dark ? 0.18 : 0.08) }
    private var pillFill:     Color { appPurple.opacity(scheme == .dark ? 0.22 : 0.12) }

    private var showTonePills: Bool {
        if case .context = selection { return true }
        return selection == .tool(.emailPolish)
    }
    private var hasResult: Bool { !resultText.isEmpty || isLoading }

    private var emailComponents: (subject: String, body: String)? {
        guard selection == .tool(.emailPolish),
              resultText.hasPrefix("SUBJECT:") else { return nil }
        let lines   = resultText.components(separatedBy: "\n")
        let subject = lines.first?
            .replacingOccurrences(of: "SUBJECT:", with: "")
            .trimmingCharacters(in: .whitespaces) ?? ""
        let body    = lines.dropFirst().joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (subject, body)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modePill
                inputArea
                if hasResult {
                    Divider()
                    resultArea
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WritePro")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(titleColor)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showHistory = true } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(appPurple)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear").foregroundStyle(appPurple)
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack { Spacer(); Button("Done") { editorFocused = false }.fontWeight(.semibold) }
                }
            }
            .safeAreaInset(edge: .bottom) { bottomBar }
            .sheet(isPresented: $showSelection) {
                SelectionSheetiOS(selection: $selection) {
                    showSelection = false; selectedTone = nil
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showHistory) {
                HistorySheetiOS(onSelect: { entry in
                    inputText = entry.original
                    resultText = entry.result
                })
            }
            .background(Color(.systemBackground).ignoresSafeArea(.all))
        }
    }

    private var modePill: some View {
        HStack {
            Button { showSelection = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: selection.icon).font(.system(size: 13, weight: .medium))
                    Text(selection.label).font(.system(size: 14, weight: .semibold))
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold))
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(appPurple).foregroundStyle(.white).clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 4)
    }

    private var inputArea: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $inputText)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12).padding(.top, 8)
                .focused($editorFocused)
            if inputText.isEmpty {
                Text("Paste or type your text here…")
                    .font(.body)
                    .foregroundStyle(Color(.placeholderText))
                    .padding(.top, 16).padding(.leading, 17)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultArea: some View {
        ScrollView {
            if isLoading && resultText.isEmpty {
                HStack { Spacer(); ProgressView().padding(.top, 24); Spacer() }
            } else if let email = emailComponents {
                emailCard(email)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("RESULT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(appPurple)
                    Text(resultText)
                        .font(.body).textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    actionRow(copyText: resultText, useAsInput: resultText)
                }
                .padding(14)
                .background(resultCardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emailCard(_ email: (subject: String, body: String)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SUBJECT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(appPurple)
                HStack {
                    Text(email.subject)
                        .font(.system(size: 15, weight: .medium))
                        .textSelection(.enabled)
                    Spacer()
                    Button { UIPasteboard.general.string = email.subject } label: {
                        Image(systemName: "doc.on.doc").foregroundStyle(.secondary)
                    }
                }
            }
            Divider()
            Text(email.body).font(.body).textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
            actionRow(copyText: email.body, useAsInput: email.body)
        }
        .padding(14)
        .background(resultCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(12)
    }

    private func actionRow(copyText: String, useAsInput: String) -> some View {
        HStack(spacing: 16) {
            Button { runImprove() } label: {
                Label("Try Again", systemImage: "arrow.clockwise").font(.system(size: 13))
            }
            Button {
                inputText = useAsInput; resultText = ""
            } label: {
                Label("Use as Input", systemImage: "arrow.uturn.left").font(.system(size: 13))
            }
            Spacer()
            Button { UIPasteboard.general.string = copyText } label: {
                Label("Copy", systemImage: "doc.on.doc").font(.system(size: 13))
            }
        }
        .foregroundStyle(appPurple)
        .padding(.top, 4)
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            if showTonePills {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ToneModifier.allCases) { tone in
                            Button {
                                selectedTone = selectedTone == tone ? nil : tone
                            } label: {
                                Text(tone.label)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.vertical, 6).padding(.horizontal, 12)
                                    .background(selectedTone == tone ? appPurple : pillFill)
                                    .foregroundStyle(selectedTone == tone ? Color.white : appPurple)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            Button { runImprove() } label: {
                Group {
                    if isLoading { ProgressView().tint(.white) }
                    else { Text("Improve").font(.system(size: 16, weight: .semibold)) }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(inputText.isEmpty || isLoading ? appPurple.opacity(0.4) : appPurple)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(inputText.isEmpty || isLoading)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func runImprove() {
        editorFocused = false
        Task {
            isLoading = true
            resultText = ""
            let (system, user) = PromptBuilder.build(
                selection: selection, tone: selectedTone, input: inputText
            )
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
}

struct SelectionSheetiOS: View {
    @Binding var selection: SidebarSelection
    var onSelect: () -> Void
    private let appPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

    var body: some View {
        NavigationStack {
            List {
                Section("Context") {
                    ForEach(StyleContext.allCases) { style in
                        Button {
                            selection = .context(style); onSelect()
                        } label: {
                            Label(style.label, systemImage: style.icon)
                                .foregroundStyle(selection == .context(style) ? appPurple : Color.primary)
                        }
                    }
                }
                Section("Tools") {
                    ForEach(Tool.allCases) { tool in
                        Button {
                            selection = .tool(tool); onSelect()
                        } label: {
                            Label(tool.label, systemImage: tool.icon)
                                .foregroundStyle(selection == .tool(tool) ? appPurple : Color.primary)
                        }
                    }
                }
            }
            .navigationTitle("Select Mode")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
