#if os(macOS)
import SwiftUI

struct MistakePopoverView: View {
    let mistake: GrammarMistake
    let onApply: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(mistake.issue)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(NSColor.secondaryLabelColor))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Suggestion")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(NSColor.secondaryLabelColor))
                Text(mistake.suggestion)
                    .font(.system(size: 13))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
            }

            Button("Apply Fix") { onApply() }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 124/255, green: 58/255, blue: 237/255))
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(width: 280)
    }
}

#endif
