import Foundation

final class HistoryService: ObservableObject {
    static let shared = HistoryService()
    private let key = "writepro.history"
    private let maxEntries = 20

    @Published private(set) var entries: [HistoryEntry] = []

    private init() { load() }

    func add(mode: String, original: String, result: String) {
        let entry = HistoryEntry(mode: mode, original: original, result: result)
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func clear() {
        entries = []
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = decoded
    }
}
