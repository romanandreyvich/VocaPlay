import Foundation

final class StorageManager {
    static let shared = StorageManager()

    private let groupsKey = "wordGroups"

    private init() {}

    func saveGroups(_ groups: [WordGroup]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
        }
    }

    func loadGroups() -> [WordGroup] {
        guard let data = UserDefaults.standard.data(forKey: groupsKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([WordGroup].self, from: data)) ?? []
    }

    func addGroup(_ group: WordGroup) {
        var groups = loadGroups()
        groups.append(group)
        saveGroups(groups)
    }

    func updateGroup(_ group: WordGroup) {
        var groups = loadGroups()
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveGroups(groups)
        }
    }

    func deleteGroup(_ group: WordGroup) {
        var groups = loadGroups()
        groups.removeAll { $0.id == group.id }
        saveGroups(groups)
    }

    func addWord(_ word: Word, to group: WordGroup) {
        var groups = loadGroups()
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].words.append(word)
            saveGroups(groups)
        }
    }

    func updateWord(_ word: Word, in group: WordGroup) {
        var groups = loadGroups()
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }),
           let wordIndex = groups[groupIndex].words.firstIndex(where: { $0.id == word.id }) {
            groups[groupIndex].words[wordIndex] = word
            saveGroups(groups)
        }
    }

    func deleteWord(_ word: Word, from group: WordGroup) {
        var groups = loadGroups()
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].words.removeAll { $0.id == word.id }
            saveGroups(groups)
        }
    }
}
