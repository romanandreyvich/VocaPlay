import Foundation

struct WordGroup: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var language: Language
    var words: [Word]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, language: Language, words: [Word] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.language = language
        self.words = words
        self.createdAt = createdAt
    }

    var wordCount: Int {
        words.count
    }

    var learnedCount: Int {
        words.filter { $0.isLearned }.count
    }
}
