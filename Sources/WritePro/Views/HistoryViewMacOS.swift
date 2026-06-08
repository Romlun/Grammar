#if os(macOS)
import SwiftUI

struct HistoryViewMacOS: View {
    @ObservedObject private var history = HistoryService.shared
    var onSelect: (HistoryEntry) -> Void
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("History")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                if !history.entries.isEmpty {
                    Button("Clear All") { history.clear() }
                        .foregroundStyle(.red)
                        .buttonStyle(.plain)
                        .font(.system(size: 12))
                }
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(NSColor.tertiaryLabelColor))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, DesignTokens.sp4)
            .padding(.vertical, DesignTokens.sp3)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            if history.entries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 36))
                        .foregroundStyle(DesignTokens.accent.opacity(0.4))
                    Text("No history yet")
                        .font(.system(size: 13, weight: .medium))
                    Text("Your last 20 rewrites will appear here.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(history.entries) { entry in
                    Button {
                        onSelect(entry)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(entry.mode)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(DesignTokens.accent)
                                    .padding(.horizontal, DesignTokens.sp2)
                                    .padding(.vertical, 2)
                                    .background(DesignTokens.accentSubtle)
                                    .clipShape(Capsule())
                                Spacer()
                                Text(dateFormatter.string(from: entry.date))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.result)
                                .font(.system(size: 12))
                                .lineLimit(2)
                                .foregroundStyle(.primary)
                            Text(entry.original)
                                .font(.system(size: 11))
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 3)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 380, height: 480)
    }
}
#endif
