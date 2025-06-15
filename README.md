# PacTacToe 🦙

A fun twist on the classic Tic-Tac-Toe game for iOS, built with SwiftUI. Play solo against an intelligent AI, with friends on the same device, or connect with nearby players using peer-to-peer networking.

## Features

### Game Modes
- **Single Device**: Take turns with a friend on the same device
- **Bot Mode**: Challenge an intelligent AI opponent
- **Peer-to-Peer**: Play with friends over local network using MultipeerConnectivity

### AI Intelligence
The bot uses strategic gameplay with priority-based decision making:
1. Win the game if possible
2. Block opponent's winning move
3. Take center position
4. Take corner positions
5. Take edge positions

### Multiplayer Networking
- Automatic peer discovery on local network
- Real-time game synchronization
- Invitation system for connecting with friends

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `PacTacToe.xcodeproj` in Xcode
3. Build and run on your iOS device or simulator

## How to Play

1. **Set Your Name**: Enter your player name when first launching the app
2. **Choose Game Mode**: Select from single device, bot, or peer-to-peer
3. **Start Playing**: Take turns placing X's and O's to get three in a row
4. **Win Conditions**: Get three of your pieces in a row (horizontal, vertical, or diagonal)

## Architecture

Built using modern iOS development patterns:
- **SwiftUI** for declarative UI
- **MVVM Architecture** with ObservableObject
- **MultipeerConnectivity** for local networking
- **AppStorage** for persistent user preferences
- **Async/Await** for AI move processing

## Project Structure

```
PacTacToe/
├── AppEntry.swift              # Main app entry point
├── StartView.swift             # Game mode selection
├── YourNameView.swift          # User name input
├── Game Screen/
│   ├── GameService.swift       # Core game logic and AI
│   ├── GameView.swift          # Main game interface
│   ├── SquareView.swift        # Individual game squares
│   └── GameSquare.swift        # Game square data model
├── MultiPeerConnectivity/
│   ├── MPConnectionManager.swift  # Peer-to-peer networking
│   ├── MPGameMove.swift          # Network protocol
│   └── MPPeersView.swift         # Peer discovery UI
├── Models/
│   └── GameModels.swift        # Core data structures
└── Utilities/
    └── ViewModifiers.swift     # Custom SwiftUI modifiers
```

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the game!

## License

This project is available under the MIT License.