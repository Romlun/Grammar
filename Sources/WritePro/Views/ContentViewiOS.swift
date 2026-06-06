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
    @State private var showResult       = false
    @State private var showSelection    = false
    @State private var showSettings     = false

    private var showTonePills: Bool {
        if case .context = selection { return true }
        return selection == .tool(.emailPolish)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                selectionButton
                Divider()
                editor
                Divider()
                if showTonePills { tonePills }
                improveButton
            }
            .navigationTitle("WritePro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSelection) {
                SelectionSheetiOS(selection: $selection) { showSelection = false }
            }
            .sheet(isPresented: $showResult) {
                ResultSheetiOS(
                    resultText: $resultText,
                    inputText:  $inputText,
                    isLoading:  $isLoading,
                    selection:  selection,
                    onTryAgain: { showResult = false; runImprove() }
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var selectionButton: some View {
        Button { showSelection = true } label: {
            HStack(spacing: 6) {
                Image(systemName: selection.icon).font(.system(size: 13))
                Text(selection.label).font(.system(size: 14, weight: .medium))
                Image(systemName: "chevron.down").font(.system(size: 11))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(appPurple)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $inputText)
                .font(.body)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if inputText.isEmpty {
                Text("Paste or type your text here…")
                    .font(.body)
                    .foregroundStyle(Color(.placeholderText))
                    .padding(.top, 16)
                    .padding(.leading, 13)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tonePills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ToneModifier.allCases) { tone in
                    Button {
                        selectedTone = selectedTone == tone ? nil : tone
                    } label: {
                        Text(tone.label)
                            .font(.system(size: 12))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                            .background(selectedTone == tone ? appPurple.opacity(0.15) : Color.clear)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(
                                selectedTone == tone ? appPurple : Color(.separator),
                                lineWidth: 1
                            ))
                            .foregroundStyle(selectedTone == tone ? appPurple : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
    }

    private var improveButton: some View {
        Button { runImprove() } label: {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Improve")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(inputText.isEmpty || isLoading ? appPurple.opacity(0.4) : appPurple)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(inputText.isEmpty || isLoading)
        .padding(16)
    }

    private func runImprove() {
        Task {
            isLoading = true
            resultText = ""
            showResult = true
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
                            selection = .context(style)
                            onSelect()
                        } label: {
                            Label(style.label, systemImage: style.icon)
                                .foregroundStyle(selection == .context(style) ? appPurple : Color.primary)
                        }
                    }
                }
                Section("Tools") {
                    ForEach(Tool.allCases) { tool in
                        Button {
                            selection = .tool(tool)
                            onSelect()
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

struct ResultSheetiOS: View {
    @Binding var resultText: String
    @Binding var inputText:  String
    @Binding var isLoading:  Bool
    let selection: SidebarSelection
    var onTryAgain: () -> Void
    @Environment(\.dismiss) private var dismiss
    private let appPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

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
            Group {
                if isLoading && resultText.isEmpty {
                    ProgressView("Improving…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let email = emailComponents {
                    emailView(email: email)
                } else {
                    plainResultView
                }
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { UIPasteboard.general.string = resultText } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
        }
    }

    private var plainResultView: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(resultText.isEmpty ? "Waiting for result…" : resultText)
                    .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if !resultText.isEmpty {
                Divider()
                HStack(spacing: 10) {
                    actionButton("Try Again", icon: "arrow.clockwise") { onTryAgain() }
                    actionButton("Use as Input", icon: "arrow.uturn.left") {
                        inputText = resultText; dismiss()
                    }
                }
                .padding(12)
            }
        }
    }

    private func emailView(email: (subject: String, body: String)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Subject").font(.caption).foregroundStyle(.secondary)
                    Text(email.subject)
                        .font(.system(size: 15, weight: .medium))
                        .textSelection(.enabled)
                }
                Spacer()
                Button { UIPasteboard.general.string = email.subject } label: {
                    Image(systemName: "doc.on.doc").foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            Divider()
            ScrollView {
                Text(email.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            HStack(spacing: 10) {
                actionButton("Try Again", icon: "arrow.clockwise") { onTryAgain() }
                actionButton("Copy Body", icon: "doc.on.doc") {
                    UIPasteboard.general.string = email.body
                }
            }
            .padding(12)
        }
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
#endif
