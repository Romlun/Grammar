import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedAction: Action = .fixGrammar
    @State private var selectedStyle: StyleContext = .general
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSettings: Bool = false

    var body: some View {
        HSplitView {
            // Left panel
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                    TextEditor(text: $inputText)
                        .font(.body)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ActionPickerView(selectedAction: $selectedAction)

                StylePickerView(selectedStyle: $selectedStyle)

                Button("Improve") {
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
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || inputText.isEmpty)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)

            // Right panel
            VStack(alignment: .leading, spacing: 12) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        Text(resultText.isEmpty ? "Your improved text will appear here" : resultText)
                            .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(resultText, forType: .string)
                }
                .disabled(resultText.isEmpty || isLoading)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 900, height: 500)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
