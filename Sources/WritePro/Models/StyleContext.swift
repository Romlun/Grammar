import Foundation

enum StyleContext: String, CaseIterable, Identifiable {
    case everyday
    case professional
    case church
    case socialMedia
    case personal
    case coverLetter

    var id: Self { self }

    var icon: String {
        switch self {
        case .everyday:     return "bubble.left"
        case .professional: return "briefcase"
        case .church:       return "heart"
        case .socialMedia:  return "antenna.radiowaves.left.and.right"
        case .personal:     return "person"
        case .coverLetter:  return "doc.text"
        }
    }

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
