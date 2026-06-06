import Foundation

enum ToneModifier: String, CaseIterable, Identifiable {
    case confident
    case formal
    case warm
    case engaging
    case casual
    case detailed
    case direct
    case encouraging
    case biblical

    var id: Self { self }

    var label: String {
        switch self {
        case .confident:   return "Confident"
        case .formal:      return "Formal"
        case .warm:        return "Warm"
        case .engaging:    return "Engaging"
        case .casual:      return "Casual"
        case .detailed:    return "Detailed"
        case .direct:      return "Direct"
        case .encouraging: return "Encouraging"
        case .biblical:    return "Biblical"
        }
    }
}
