import SwiftUI

struct SwipeCardsView: View {
    var viewModel: AppViewModel
    let group: WordGroup
    @Environment(\.dismiss) private var dismiss
    @State private var cards: [Word] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showingResult = false

    private var unlearnedWords: [Word] {
        group.words.filter { !$0.isLearned }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if cards.isEmpty || currentIndex >= cards.count {
                    ContentUnavailableView(
                        "Все слова изучены!",
                        systemImage: "checkmark.circle",
                        description: Text("Вы изучили все слова в этой группе")
                    )
                } else {
                    VStack {
                        Spacer()

                        if currentIndex < cards.count {
                            CardView(
                                word: cards[currentIndex],
                                offset: offset,
                                language: group.language
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation
                                    }
                                    .onEnded { value in
                                        handleSwipe(translation: value.translation)
                                    }
                            )
                        }

                        Spacer()

                        HStack(spacing: 40) {
                            Button {
                                swipeLeft()
                            } label: {
                                VStack {
                                    Image(systemName: "xmark")
                                        .font(.largeTitle)
                                    Text("Не знаю")
                                        .font(.caption)
                                }
                                .foregroundStyle(.red)
                            }

                            Button {
                                speakCurrentWord()
                            } label: {
                                VStack {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.largeTitle)
                                    Text("Слушать")
                                        .font(.caption)
                                }
                                .foregroundStyle(.blue)
                            }

                            Button {
                                swipeRight()
                            } label: {
                                VStack {
                                    Image(systemName: "checkmark")
                                        .font(.largeTitle)
                                    Text("Знаю")
                                        .font(.caption)
                                }
                                .foregroundStyle(.green)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Изучение слов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCards()
            }
        }
    }

    private func loadCards() {
        cards = group.words.filter { !$0.isLearned }.shuffled()
    }

    private func handleSwipe(translation: CGSize) {
        let threshold: CGFloat = 100

        if translation.width > threshold {
            swipeRight()
        } else if translation.width < -threshold {
            swipeLeft()
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }

    private func swipeRight() {
        guard currentIndex < cards.count else { return }
        let word = cards[currentIndex]
        viewModel.markWordAsLearned(word, in: group)
        animateCardOut(direction: .right)
    }

    private func swipeLeft() {
        guard currentIndex < cards.count else { return }
        let word = cards[currentIndex]
        viewModel.markWordAsNotLearned(word, in: group)
        animateCardOut(direction: .left)
    }

    private func animateCardOut(direction: SwipeDirection) {
        withAnimation(.easeOut(duration: 0.3)) {
            switch direction {
            case .left:
                offset = CGSize(width: -500, height: 0)
            case .right:
                offset = CGSize(width: 500, height: 0)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            currentIndex += 1
        }
    }

    private func speakCurrentWord() {
        guard currentIndex < cards.count else { return }
        TextToSpeechService.shared.speak(cards[currentIndex].original, language: group.language)
    }

    private enum SwipeDirection {
        case left, right
    }
}

struct CardView: View {
    let word: Word
    let offset: CGSize
    let language: Language
    @State private var showTranslation = false

    private var rotation: Double {
        Double(offset.width / 20)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(word.original)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)

            if showTranslation {
                Text(word.translation)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            } else {
                Button {
                    withAnimation {
                        showTranslation = true
                    }
                } label: {
                    Text("Показать перевод")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
                .padding(.top, 20)
            }

            Button {
                TextToSpeechService.shared.speak(word.original, language: language)
            } label: {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.largeTitle)
            }
            .padding(.top, 20)
        }
        .padding(40)
        .frame(width: 300, height: 400)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .primary.opacity(0.3), radius: 15, x: 0, y: 2)
        )
        .offset(offset)
        .rotationEffect(.degrees(rotation))
    }
}
