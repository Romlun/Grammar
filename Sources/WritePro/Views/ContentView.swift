import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedAction: Action = .fixGrammar
    @State private var selectedStyle: StyleContext = .general
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        HSplitView {
            // Left panel
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $inputText)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                ActionPickerView(selectedAction: $selectedAction)

                StylePickerView(selectedStyle: $selectedStyle)

                Button("Improve") {
                    // action placeholder
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || inputText.isEmpty)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)

            // Right panel
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    Text(resultText.isEmpty ? "Your improved text will appear here" : resultText)
                        .foregroundStyle(resultText.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(resultText, forType: .string)
                }
                .disabled(resultText.isEmpty)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 900, height: 500)
    }
}
