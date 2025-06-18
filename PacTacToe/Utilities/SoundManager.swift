import Foundation
import AVFoundation
import AudioToolbox
import UIKit

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    @Published var isSoundEnabled = true
    
    private init() {
        setupAudioSession()
        loadSoundPreference()
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
            // First try to load from Assets catalog
            if let asset = NSDataAsset(name: filename) {
                do {
                    let player = try AVAudioPlayer(data: asset.data)
                    player.prepareToPlay()
                    audioPlayers[key] = player
                    print("✅ Successfully loaded sound from Assets: \(filename)")
                } catch {
                    print("❌ Failed to load sound from Assets \(filename): \(error)")
                }
            } 
            // Then try regular bundle resource
            else if let url = Bundle.main.url(forResource: filename, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[key] = player
                    print("✅ Successfully loaded sound from bundle: \(filename)")
                } catch {
                    print("❌ Failed to load sound \(filename): \(error)")
                }
            } else {
                print("⚠️ Sound file not found: \(filename).wav")
            }
        }
        print("🔊 SoundManager loaded \(audioPlayers.count) out of \(soundFiles.count) sounds")
    }
    
    func playSound(_ soundName: String) {
        guard isSoundEnabled else { 
            print("🔇 Sound disabled, not playing: \(soundName)")
            return 
        }
        
        guard let player = audioPlayers[soundName] else {
            print("⚠️ Sound not found: \(soundName), using system sound")
            // Use system sounds as fallback
            playSystemSound(for: soundName)
            return
        }
        
        player.stop()
        player.currentTime = 0
        let success = player.play()
        print("🔊 Playing sound: \(soundName) - Success: \(success)")
    }
    
    private func playSystemSound(for soundName: String) {
        let soundID: SystemSoundID
        
        switch soundName {
        case "move", "button":
            soundID = 1104 // Tink sound
        case "win", "game_start":
            soundID = 1025 // Bell sound
        case "lose", "error":
            soundID = 1073 // Error sound
        case "tie":
            soundID = 1103 // Beep sound
        case "thinking":
            soundID = 1106 // Pop sound
        default:
            soundID = 1104 // Default tink
        }
        
        AudioServicesPlaySystemSound(soundID)
        print("🔊 Played system sound ID: \(soundID) for: \(soundName)")
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
    }
    
    func loadSoundPreference() {
        isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        print("🔊 Sound preference loaded: \(isSoundEnabled)")
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