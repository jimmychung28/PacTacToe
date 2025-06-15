# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

PacTacToe is a SwiftUI-based Tic-Tac-Toe game for iOS with three game modes:
- **Single Device**: Two players sharing one device
- **Bot Mode**: Player vs AI with strategic gameplay
- **Peer-to-Peer**: Local multiplayer using MultipeerConnectivity

## Build Commands

```bash
# Build for development
xcodebuild -project PacTacToe.xcodeproj -scheme PacTacToe -configuration Debug

# Build for release
xcodebuild -project PacTacToe.xcodeproj -scheme PacTacToe -configuration Release -sdk iphoneos

# Clean build
xcodebuild -project PacTacToe.xcodeproj -scheme PacTacToe clean
```

## Architecture Overview

The app follows MVVM with SwiftUI and uses these key patterns:

- **App Entry**: `AppEntry.swift` handles conditional navigation based on user name storage
- **State Management**: `GameService` is the main `@ObservableObject` managing game state
- **Dependency Injection**: Uses `@EnvironmentObject` for sharing `GameService` across views
- **Async Operations**: AI moves use `async/await` with 1-second thinking delay

### Key Components

**GameService** (`Game Screen/GameService.swift`):
- Core game logic and state management
- AI strategy with win/block/center/corner/edge priority
- Handles all three game modes

**MPConnectionManager** (`MultiPeerConnectivity/MPConnectionManager.swift`):
- Manages peer-to-peer connections using MultipeerConnectivity
- Service type: "Pac-Tac-Toe"
- Handles invitation/discovery flow and game move synchronization

**Navigation Flow**:
1. `YourNameView` → `StartView` → `GameView` (single/bot)
2. `YourNameView` → `StartView` → `MPPeersView` → `GameView` (peer-to-peer)

## Development Notes

- Uses `@AppStorage("yourName")` for persistent name storage
- AI implements strategic gameplay: win → block → center → corners → edges
- MultipeerConnectivity requires Bonjour services (`_XAndO._tcp`, `_XAndO._udp`)
- Game state is fully reactive with `@Published` properties
- All UI animations use SwiftUI's built-in `withAnimation`

## Device Compatibility

- Universal app (iPhone and iPad)
- iOS deployment target configured in project settings
- Uses `UIDevice.current.name` for bot player identification