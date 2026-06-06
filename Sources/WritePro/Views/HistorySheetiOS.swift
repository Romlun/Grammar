#if os(iOS)
import SwiftUI

struct HistorySheetiOS: View {
    @ObservedObject private var history = HistoryService.shared
    var onSelect: (HistoryEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    private let appPurple = Color(red: 124/255, green: 58/255, blue: 237/255)

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 44))
                            .foregroundStyle(appPurple.opacity(0.4))
                        Text("No history yet")
                            .font(.system(size: 17, weight: .medium))
                        Text("Your last 20 rewrites will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(history.entries) { entry in
                            Button {
                                onSelect(entry)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(entry.mode)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(appPurple)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(appPurple.opacity(0.1))
                                            .clipShape(Capsule())
                                        Spacer()
                                        Text(dateFormatter.string(from: entry.date))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(entry.result)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                    Text(entry.original)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            history.delete(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                if !history.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") { history.clear() }
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
#endif
