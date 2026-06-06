import Foundation

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mode: String
    let original: String
    let result: String

    init(mode: String, original: String, result: String) {
        self.id = UUID()
        self.date = Date()
        self.mode = mode
        self.original = original
        self.result = result
    }
}
