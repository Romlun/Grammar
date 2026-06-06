import Foundation

struct GrammarMistake: Identifiable {
    let id = UUID()
    let phrase: String
    let issue: String
    let suggestion: String
    var range: NSRange?
}
