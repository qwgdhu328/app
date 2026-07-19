import Foundation

enum Config {
    static var openRouterAPIKey: String {
        if let key = Bundle.main.infoDictionary?["OPENROUTER_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        if let key = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"], !key.isEmpty {
            return key
        }
        return ""
    }
}
