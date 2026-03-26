import AVFoundation

@Observable
final class TextToSpeechService {
    static let shared = TextToSpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking = false

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func speak(_ text: String, language: Language, completion: (() -> Void)? = nil) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isSpeaking = true

        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            completion?()
            self?.isSpeaking = false
        }
    }

    func speakWordAndTranslation(word: Word, language: Language, delay: TimeInterval = 1.5, completion: (() -> Void)? = nil) {
        speak(word.original, language: language) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self?.speak(word.translation, language: .russian) {
                    completion?()
                }
            }
        }
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
        }
    }

    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
}
