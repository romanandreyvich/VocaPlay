import CarPlay
import SwiftUI

final class CarPlayController: NSObject {
    static let shared = CarPlayController()

    private var interfaceController: CPInterfaceController?

    func carPlaySceneDidConnect(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        showGroupsList()
    }

    private func showGroupsList() {
        let groups = StorageManager.shared.loadGroups()
        let template = createGroupsListTemplate(groups: groups)
        interfaceController?.setRootTemplate(template, animated: true, completion: nil)
    }

    private func createGroupsListTemplate(groups: [WordGroup]) -> CPListTemplate {
        let sections: [CPListSection] = groups.map { group in
            let item = CPListItem(
                text: group.name,
                detailText: "\(group.language.flag) \(group.language.rawValue) - \(group.wordCount) слов"
            )
            item.accessoryType = .disclosureIndicator
            item.handler = { [weak self] _, completion in
                self?.showGroupWords(group: group)
                completion()
            }
            return CPListSection(items: [item])
        }

        let template = CPListTemplate(title: "Группы слов", sections: sections)
        template.tabImage = UIImage(systemName: "folder")
        template.emptyViewTitleVariants = ["Нет групп"]
        template.emptyViewSubtitleVariants = ["Создайте группу в приложении"]
        return template
    }

    private func showGroupWords(group: WordGroup) {
        guard !group.words.isEmpty else {
            let emptyItem = CPListItem(text: "Нет слов", detailText: "Добавьте слова в приложении")
            let template = CPListTemplate(title: group.name, sections: [CPListSection(items: [emptyItem])])
            interfaceController?.pushTemplate(template, animated: true, completion: nil)
            return
        }

        let playAllItem = CPListItem(
            text: "Воспроизвести все",
            detailText: "Круговое воспроизведение"
        )
        playAllItem.accessoryType = .disclosureIndicator
        playAllItem.handler = { [weak self] _, completion in
            self?.startCircularPlayback(for: group)
            completion()
        }

        let wordItems = group.words.map { word in
            let item = CPListItem(text: word.original, detailText: word.translation)
            item.accessoryType = .none
            item.handler = { _, completion in
                TextToSpeechService.shared.speak(word.original, language: group.language)
                completion()
            }
            return item
        }

        let allItems = [playAllItem] + wordItems
        let sections = [CPListSection(items: allItems)]
        let template = CPListTemplate(title: group.name, sections: sections)
        template.tabImage = UIImage(systemName: "textformat.abc")
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }

    private func startCircularPlayback(for group: WordGroup) {
        let words = group.words.shuffled()
        playWordCircularly(words: words, group: group, index: 0)
    }

    private func playWordCircularly(words: [Word], group: WordGroup, index: Int) {
        guard !words.isEmpty else { return }

        let currentIndex = index % words.count
        let word = words[currentIndex]

        TextToSpeechService.shared.speakWordAndTranslation(word: word, language: group.language) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.playWordCircularly(words: words, group: group, index: currentIndex + 1)
            }
        }
    }
}
