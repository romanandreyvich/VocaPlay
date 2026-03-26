import Foundation

enum Language: String, Codable, CaseIterable, Identifiable {
    case english = "Английский"
    case spanish = "Испанский"
    case russian = "Русский"

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .russian: return "ru-RU"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .russian: return "🇷🇺"
        }
    }
}
