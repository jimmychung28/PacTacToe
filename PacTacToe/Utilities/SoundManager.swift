import Foundation
import AVFoundation

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    @Published var isSoundEnabled = true
    
    private init() {
        setupAudioSession()
        loadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadSounds() {
        let soundFiles = [
            "move": "move_sound",
            "win": "win_sound", 
            "lose": "lose_sound",
            "tie": "tie_sound",
            "button": "button_sound",
            "error": "error_sound",
            "thinking": "thinking_sound",
            "game_start": "game_start_sound"
        ]
        
        for (key, filename) in soundFiles {
            if let url = Bundle.main.url(forResource: filename, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[key] = player
                } catch {
                    print("Failed to load sound \(filename): \(error)")
                }
            }
        }
    }
    
    func playSound(_ soundName: String) {
        guard isSoundEnabled else { return }
        
        audioPlayers[soundName]?.stop()
        audioPlayers[soundName]?.currentTime = 0
        audioPlayers[soundName]?.play()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
    }
    
    func loadSoundPreference() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
    }
}

extension SoundManager {
    enum SoundEffect {
        static let move = "move"
        static let win = "win"
        static let lose = "lose"
        static let tie = "tie"
        static let button = "button"
        static let error = "error"
        static let thinking = "thinking"
        static let gameStart = "game_start"
    }
}