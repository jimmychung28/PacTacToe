import Foundation
import UIKit

@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @Published var isHapticEnabled = true
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {
        loadHapticPreference()
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }
    
    func playHaptic(_ type: HapticType) {
        guard isHapticEnabled else { return }
        
        switch type {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .selection:
            selection.selectionChanged()
        case .success:
            notification.notificationOccurred(.success)
        case .warning:
            notification.notificationOccurred(.warning)
        case .error:
            notification.notificationOccurred(.error)
        }
    }
    
    func toggleHaptic() {
        isHapticEnabled.toggle()
        UserDefaults.standard.set(isHapticEnabled, forKey: "hapticEnabled")
    }
    
    private func loadHapticPreference() {
        isHapticEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
    }
}

enum HapticType {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}

extension HapticManager {
    enum Feedback {
        static let move = HapticType.light
        static let win = HapticType.success
        static let lose = HapticType.error
        static let tie = HapticType.warning
        static let button = HapticType.selection
        static let error = HapticType.error
        static let thinking = HapticType.medium
    }
}