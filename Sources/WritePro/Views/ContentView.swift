import SwiftUI

private let purple       = Color(red: 124/255, green: 58/255,  blue: 237/255)
private let sidebarBg    = Color(red: 30/255,  green: 30/255,  blue: 30/255)
private let unselected   = Color(red: 153/255, green: 153/255, blue: 153/255)
private let sectionLabel = Color(red: 85/255,  green: 85/255,  blue: 85/255)

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedAction: Action = .fixGrammar
    @State private var selectedStyle: StyleContext = .everydayMessages
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSettings: Bool = false

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
            Text("ACTION")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(sectionLabel)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 6)

            ForEach(Action.allCases) { action in
                Button {
                    selectedAction = action
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: action.icon)
                            .frame(width: 16, alignment: .center)
                        Text(action.label)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(selectedAction == action ? purple : Color.clear)
                    .cornerRadius(6)
                    .foregroundStyle(selectedAction == action ? Color.white : unselected)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
            }

            Spacer()
        }
        .frame(width: 180)
        .background(sidebarBg)
    }

    // MARK: - Editor panel

    private var editorPanel: some View {
        TextEditor(text: $inputText)
            .font(.body)
            .padding(8)
            .scrollContentBackground(.hidden)
            .background(Color(NSColor.textBackgroundColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Result panel

    private var resultPanel: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    Text(resultText.isEmpty ? "Your improved text will appear here" : resultText)
                        .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(StyleContext.allCases) { style in
                        Button {
                            selectedStyle = style
                        } label: {
                            Text(style.label)
                                .font(.system(size: 11))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(selectedStyle == style ? purple.opacity(0.15) : Color.clear)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(
                                    selectedStyle == style ? purple : Color(NSColor.separatorColor),
                                    lineWidth: 1
                                ))
                                .foregroundStyle(selectedStyle == style ? purple : Color(NSColor.secondaryLabelColor))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }

            Spacer()

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
}
