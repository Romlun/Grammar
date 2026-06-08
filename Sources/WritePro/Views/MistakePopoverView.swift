#if os(macOS)
import SwiftUI

struct MistakePopoverView: View {
    let mistake: GrammarMistake
    let onApply: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.sp3) {
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

            VStack(alignment: .leading, spacing: DesignTokens.sp1) {
                Text("Suggestion")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(NSColor.secondaryLabelColor))
                Text(mistake.suggestion)
                    .font(.system(size: 13))
                    .padding(DesignTokens.sp2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusCard))
            }

            Button("Apply Fix") { onApply() }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.accent)
                .frame(maxWidth: .infinity)
        }
        .padding(DesignTokens.sp4)
        .frame(width: 280)
    }
}

#endif
