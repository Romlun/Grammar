import Foundation

enum Tool: String, CaseIterable, Identifiable {
    case emailPolish
    case fixGrammar
    case makeShorter
    case explainMistakes

    var id: Self { self }

    var icon: String {
        switch self {
        case .emailPolish:     return "envelope.badge"
        case .fixGrammar:      return "checkmark.circle"
        case .makeShorter:     return "scissors"
        case .explainMistakes: return "list.bullet.clipboard"
        }
    }

    var label: String {
        switch self {
        case .emailPolish:     return "Email Polish"
        case .fixGrammar:      return "Fix Grammar"
        case .makeShorter:     return "Make Shorter"
        case .explainMistakes: return "Explain Mistakes"
        }
    }
}
