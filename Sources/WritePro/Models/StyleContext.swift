import Foundation

enum StyleContext: String, CaseIterable, Identifiable {
    case everyday
    case professional
    case church
    case socialMedia
    case personal
    case coverLetter

    var id: Self { self }

    var label: String {
        switch self {
        case .everyday:     return "Everyday"
        case .professional: return "Professional"
        case .church:       return "Church"
        case .socialMedia:  return "Social Media"
        case .personal:     return "Personal"
        case .coverLetter:  return "Cover Letter"
        }
    }
}
