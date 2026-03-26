import Foundation
import SwiftUI

@Observable
final class AppViewModel {
    var groups: [WordGroup] = []
    var selectedGroup: WordGroup?

    private let storage = StorageManager.shared

    init() {
        loadGroups()
    }

    func loadGroups() {
        groups = storage.loadGroups()
    }

    func addGroup(name: String, language: Language) {
        let group = WordGroup(name: name, language: language)
        storage.addGroup(group)
        loadGroups()
    }

    func deleteGroup(_ group: WordGroup) {
        storage.deleteGroup(group)
        loadGroups()
    }

    func addWord(original: String, translation: String, to group: WordGroup) {
        let word = Word(original: original, translation: translation)
        storage.addWord(word, to: group)
        loadGroups()
    }

    func updateWord(_ word: Word, in group: WordGroup) {
        storage.updateWord(word, in: group)
        loadGroups()
    }

    func deleteWord(_ word: Word, from group: WordGroup) {
        storage.deleteWord(word, from: group)
        loadGroups()
    }

    func markWordAsLearned(_ word: Word, in group: WordGroup) {
        var updatedWord = word
        updatedWord.isLearned = true
        updateWord(updatedWord, in: group)
    }

    func markWordAsNotLearned(_ word: Word, in group: WordGroup) {
        var updatedWord = word
        updatedWord.isLearned = false
        updateWord(updatedWord, in: group)
    }

    func getGroup(by id: UUID) -> WordGroup? {
        groups.first { $0.id == id }
    }
}
