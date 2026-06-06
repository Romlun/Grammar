import Foundation

struct KeychainService {
    private static let key = "writepro.apikey"

    static func save(apiKey: String) -> Bool {
        UserDefaults.standard.set(apiKey, forKey: key)
        return true
    }

    static func load() -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
