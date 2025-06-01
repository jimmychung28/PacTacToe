import SwiftUI
import UIKit

// MARK: - Device Detection
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return mapToDeviceName(identifier: identifier)
    }
    
    private func mapToDeviceName(identifier: String) -> String {
        switch identifier {
        // iPhone models
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,2": return "iPhone 13 mini"
        case "iPhone14,3": return "iPhone 13"
        case "iPhone14,4": return "iPhone 13 Pro"
        case "iPhone14,5": return "iPhone 13 Pro Max"
        case "iPhone14,6": return "iPhone SE (3rd generation)"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        
        // iPad models
        case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
        case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
        case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"
        case "iPad14,3", "iPad14,4": return "iPad Air (5th generation)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,7", "iPad14,8": return "iPad Pro (12.9-inch) (6th generation)"
        
        // Simulator
        case "i386", "x86_64", "arm64":
            if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return mapToDeviceName(identifier: simulatorModelIdentifier) + " (Simulator)"
            }
            return "iOS Simulator"
            
        default:
            // Fallback for unknown devices
            if identifier.hasPrefix("iPhone") {
                return "iPhone"
            } else if identifier.hasPrefix("iPad") {
                return "iPad"
            } else {
                return "iOS Device"
            }
        }
    }
}

enum GameType {
    case single, bot, peer, undetermined
    
    var description: String {
        let deviceName = UIDevice.current.modelName
        
        switch self {
        case .single:
            return "Share your \(deviceName) and play against a friend."
        case .bot:
            return "Play against this \(deviceName)."
        case .peer:
            return "Invite someone near you who has this app running to play."
        case .undetermined:
            return ""
        }
    }
}

enum GamePiece: String, Equatable {
    case x, o
    var image: Image {
        Image(self.rawValue)
    }
}


struct Player: Equatable {
    let gamePiece: GamePiece
    var name: String
    var moves: [Int] = []
    var isCurrent = false
    var isWinner: Bool {
        for moves in Move.winningMoves {
            if moves.allSatisfy(self.moves.contains) {
                return true
            }
        }
        return false
    }
}

enum Move {
    static var all = [1,2,3,4,5,6,7,8,9]

    static var winningMoves = [
        [1,2,3],
        [4,5,6],
        [7,8,9],
        [1,4,7],
        [2,5,8],
        [3,6,9],
        [1,5,9],
        [3,5,7]
    ]
}
