import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                Text("Anthropic API Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("sk-ant-...", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Save") {
                    _ = KeychainService.save(apiKey: apiKey)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.accent)
                .disabled(apiKey.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .onAppear {
            apiKey = KeychainService.load() ?? ""
        }
    }
}
