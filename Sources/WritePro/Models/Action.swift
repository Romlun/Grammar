import Foundation

enum Action: String, CaseIterable, Identifiable {
    case quickPolish
    case fixGrammar
    case makeProfessional
    case makeNatural
    case makeShorter
    case makePolite
    case makeConfident
    case explainMistakes

    var id: Self { self }

    var icon: String {
        switch self {
        case .quickPolish:      return "sparkles"
        case .fixGrammar:       return "pencil.line"
        case .makeProfessional: return "briefcase"
        case .makeNatural:      return "bubble.left"
        case .makeShorter:      return "scissors"
        case .makePolite:       return "heart"
        case .makeConfident:    return "bolt"
        case .explainMistakes:  return "checklist"
        }
    }

    var label: String {
        switch self {
        case .quickPolish:      return "Quick Polish"
        case .fixGrammar:       return "Fix Grammar"
        case .makeProfessional: return "Make Professional"
        case .makeNatural:      return "Make Natural"
        case .makeShorter:      return "Make Shorter"
        case .makePolite:       return "Make More Polite"
        case .makeConfident:    return "Make More Confident"
        case .explainMistakes:  return "Explain Mistakes"
        }
    }
}
