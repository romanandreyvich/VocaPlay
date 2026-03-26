import Foundation

struct Word: Codable, Identifiable, Equatable {
    var id: UUID
    var original: String
    var translation: String
    var isLearned: Bool
    var createdAt: Date

    init(id: UUID = UUID(), original: String, translation: String, isLearned: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.original = original
        self.translation = translation
        self.isLearned = isLearned
        self.createdAt = createdAt
    }
}
