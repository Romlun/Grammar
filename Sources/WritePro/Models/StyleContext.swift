import Foundation

enum StyleContext: String, CaseIterable, Identifiable {
    case everydayMessages
    case workEmail
    case healthcare
    case business
    case church
    case immigration

    var id: Self { self }

    var label: String {
        switch self {
        case .everydayMessages: return "Everyday Messages"
        case .workEmail:   return "Work Email"
        case .healthcare:  return "Healthcare"
        case .business:    return "Business Communication"
        case .church:      return "Church / Ministry"
        case .immigration: return "Immigration / Legal"
        }
    }
}
