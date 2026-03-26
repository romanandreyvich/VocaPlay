import SwiftUI

struct PlaybackView: View {
    let group: WordGroup
    @Environment(\.dismiss) private var dismiss
    @State private var words: [Word] = []
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var showTranslation = false

    private var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(words.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                if words.isEmpty {
                    ContentUnavailableView(
                        "Все слова изучены!",
                        systemImage: "checkmark.circle",
                        description: Text("Вы изучили все слова в этой группе")
                    )
                } else {
                    VStack(spacing: 0) {
                        Spacer()

                        // Прогресс
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(uiColor: .systemGray5))
                                    .frame(height: 4)

                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)

                        // Карточка слова
                        VStack(spacing: 24) {
                            Text("\(currentIndex + 1) из \(words.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 12) {
                                Text(words[currentIndex].original)
                                    .font(.system(size: 42, weight: .bold))
                                    .multilineTextAlignment(.center)

                                if showTranslation {
                                    Text(words[currentIndex].translation)
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
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)

                            // Кнопка озвучивания
                            Button {
                                TextToSpeechService.shared.speakWordAndTranslation(
                                    word: words[currentIndex],
                                    language: group.language
                                )
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .padding(.top, 8)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 24)

                        Spacer()

                        // Управление
                        HStack(spacing: 50) {
                            Button {
                                previousWord()
                            } label: {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                            }
                            .disabled(currentIndex == 0 || isPlaying)

                            Button {
                                togglePlayback()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 70, height: 70)

                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                            }
                            .disabled(words.isEmpty)

                            Button {
                                nextWord()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                            }
                            .disabled(currentIndex >= words.count - 1 || isPlaying)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Воспроизведение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        TextToSpeechService.shared.stop()
                        dismiss()
                    }
                }
            }
            .onAppear {
                words = group.words.filter { !$0.isLearned }.shuffled()
            }
            .onDisappear {
                TextToSpeechService.shared.stop()
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        isPlaying = true
        showTranslation = false
        playCurrentWord()
    }

    private func pausePlayback() {
        TextToSpeechService.shared.pause()
        isPlaying = false
    }

    private func playCurrentWord() {
        guard currentIndex < words.count else {
            isPlaying = false
            return
        }

        let word = words[currentIndex]

        TextToSpeechService.shared.speakWordAndTranslation(word: word, language: group.language) { [self] in
            guard isPlaying else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showTranslation = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if currentIndex < words.count - 1 && isPlaying {
                    currentIndex += 1
                    showTranslation = false
                    playCurrentWord()
                } else {
                    isPlaying = false
                    currentIndex = 0
                }
            }
        }
    }

    private func nextWord() {
        guard currentIndex < words.count - 1 else { return }
        TextToSpeechService.shared.stop()
        currentIndex += 1
        showTranslation = false
    }

    private func previousWord() {
        guard currentIndex > 0 else { return }
        TextToSpeechService.shared.stop()
        currentIndex -= 1
        showTranslation = false
    }
}
