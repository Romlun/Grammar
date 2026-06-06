import Foundation

enum Action: String, CaseIterable, Identifiable {
    case fixGrammar
    case makeProfessional
    case makeNatural
    case makeShorter
    case makePolite
    case makeConfident
    case explainMistakes

    var id: Self { self }

    var label: String {
        switch self {
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
