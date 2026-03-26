import SwiftUI

struct WordListView: View {
    var viewModel: AppViewModel
    let group: WordGroup
    @State private var showingAddWord = false
    @State private var wordToDelete: Word?
    @State private var showingDeleteAlert = false
    @State private var editingWord: Word?
    @State private var showingSwipeCards = false
    @State private var showingPlayback = false

    private var currentGroup: WordGroup {
        viewModel.getGroup(by: group.id) ?? group
    }

    private func selectWordForEditing(_ word: Word) {
        viewModel.loadGroups()
        if let updated = viewModel.getGroup(by: group.id)?.words.first(where: { $0.id == word.id }) {
            editingWord = updated
        }
    }

    var body: some View {
        List {
            if !currentGroup.words.isEmpty {
                Section {
                    Button {
                        showingSwipeCards = true
                    } label: {
                        Label("Tinder изучение", systemImage: "arrow.left.arrow.right")
                    }

                    Button {
                        showingPlayback = true
                    } label: {
                        Label("Воспроизведение слов", systemImage: "speaker.wave.2")
                    }
                }
            }

            let learningWords = currentGroup.words.filter { !$0.isLearned }
            let learnedWords = currentGroup.words.filter { $0.isLearned }

            if !learningWords.isEmpty {
                Section("На изучении (\(learningWords.count))") {
                    ForEach(learningWords) { word in
                        WordRowView(word: word)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    wordToDelete = word
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.markWordAsLearned(word, in: currentGroup)
                                } label: {
                                    Label("Изучено", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                            .onTapGesture {
                                selectWordForEditing(word)
                            }
                    }
                }
            }

            if !learnedWords.isEmpty {
                Section("Изученные (\(learnedWords.count))") {
                    ForEach(learnedWords) { word in
                        WordRowView(word: word)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    wordToDelete = word
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.markWordAsNotLearned(word, in: currentGroup)
                                } label: {
                                    Label("Не изучено", systemImage: "xmark.circle")
                                }
                                .tint(.orange)
                            }
                            .onTapGesture {
                                selectWordForEditing(word)
                            }
                    }
                }
            }

            if currentGroup.words.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Нет слов",
                        systemImage: "textformat.abc",
                        description: Text("Добавьте слова для изучения")
                    )
                }
            }
        }
        .navigationTitle(Text(currentGroup.name))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddWord = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWord) {
            AddWordView(viewModel: viewModel, group: currentGroup)
                .presentationDetents([.height(400)])
        }
        .sheet(item: $editingWord) { word in
            AddWordView(viewModel: viewModel, group: currentGroup, editingWord: word)
                .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showingPlayback) {
            PlaybackView(group: currentGroup)
        }
        .sheet(isPresented: $showingSwipeCards) {
            SwipeCardsView(viewModel: viewModel, group: currentGroup)
        }
        .alert("Удалить слово?", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                if let word = wordToDelete {
                    viewModel.deleteWord(word, from: currentGroup)
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Слово будет удалено безвозвратно")
        }
        .onAppear {
            viewModel.loadGroups()
        }
    }
}

struct WordRowView: View {
    let word: Word

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.original)
                    .font(.headline)
                Text(word.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if word.isLearned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
