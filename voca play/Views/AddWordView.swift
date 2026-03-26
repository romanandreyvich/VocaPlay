import SwiftUI

struct AddWordView: View {
    var viewModel: AppViewModel
    let group: WordGroup
    var editingWord: Word?

    @Environment(\.dismiss) private var dismiss
    @State private var original: String = ""
    @State private var translation: String = ""
    @FocusState private var focusedField: Field?

    private var isEditing: Bool {
        editingWord != nil
    }

    private var isValid: Bool {
        !original.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    enum Field {
        case original, translation
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Слово") {
                    TextField("Введите слово", text: $original)
                        .focused($focusedField, equals: .original)
                        .autocorrectionDisabled()
                }

                Section("Перевод") {
                    TextField("Введите перевод", text: $translation)
                        .focused($focusedField, equals: .translation)
                        .autocorrectionDisabled()
                }

                Section {
                    HStack {
                        Spacer()
                        Button {
                            speakOriginal()
                        } label: {
                            Label("Прослушать", systemImage: "speaker.wave.2")
                        }
                        .disabled(original.isEmpty)
                        Spacer()
                    }
                }
            }
            .navigationTitle(isEditing ? "Редактировать слово" : "Добавить слово")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Сохранить" : "Добавить") {
                        saveWord()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let word = editingWord {
                    original = word.original
                    translation = word.translation
                }
            }
        }
    }

    private func saveWord() {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        let trimmedTranslation = translation.trimmingCharacters(in: .whitespacesAndNewlines).capitalized

        if let word = editingWord {
            var updatedWord = word
            updatedWord.original = trimmedOriginal
            updatedWord.translation = trimmedTranslation
            viewModel.updateWord(updatedWord, in: group)
        } else {
            viewModel.addWord(original: trimmedOriginal, translation: trimmedTranslation, to: group)
        }
        dismiss()
    }

    private func speakOriginal() {
        let word = Word(original: original, translation: translation)
        TextToSpeechService.shared.speakWordAndTranslation(word: word, language: group.language)
    }
}
