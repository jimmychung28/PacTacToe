import SwiftUI

@MainActor
class GameService: ObservableObject {
    @Published var player1 = Player(gamePiece: .x, name: "Player 1")
    @Published var player2 = Player(gamePiece: .o, name: "Player 2")
    @Published var possibleMoves = Move.all
    @Published var gameOver = false
    @Published var gameBoard = GameSquare.reset
    @Published var isThinking = false
    
    var gameType = GameType.single
    
    var currentPlayer: Player {
        if player1.isCurrent {
            return player1
        } else {
            return player2
        }
    }
    
    var gameStarted: Bool {
        player1.isCurrent || player2.isCurrent
    }
    
    var boardDisabled: Bool {
        gameOver || !gameStarted || isThinking
    }
    
    func setupGame(gameType: GameType, player1Name: String, player2Name: String) {
        switch gameType {
        case .single:
            self.gameType = .single
            player2.name = player2Name
        case .bot:
            self.gameType = .bot
            player2.name = UIDevice.current.name
        case .peer:
            self.gameType = .peer
        case .undetermined:
            break
        }
        player1.name = player1Name
    }
    
    func reset() {
        player1.isCurrent = false
        player2.isCurrent = false
        player1.moves.removeAll()
        player2.moves.removeAll()
        gameOver = false
        possibleMoves = Move.all
        gameBoard = GameSquare.reset
    }
    
    func updateMoves(index: Int) {
        if player1.isCurrent {
            player1.moves.append(index + 1)
            gameBoard[index].player = player1
        } else {
            player2.moves.append(index + 1)
            gameBoard[index].player = player2
        }
    }
    
    func checkIfWinner() {
        if player1.isWinner || player2.isWinner {
            gameOver = true
        }
    }
    
    func toggleCurrent() {
        player1.isCurrent.toggle()
        player2.isCurrent.toggle()
    }
    
    func makeMove(at index: Int) {
        if gameBoard[index].player == nil {
            withAnimation {
                updateMoves(index: index)
            }
            checkIfWinner()
            if !gameOver {
                if let matchingIndex = possibleMoves.firstIndex(where: {$0 == (index + 1)}) {
                    possibleMoves.remove(at: matchingIndex)
                }
                toggleCurrent()
                if gameType == .bot && currentPlayer.name == player2.name {
                    Task {
                        await deviceMove()
                    }
                }
            }
            if possibleMoves.isEmpty {
                gameOver = true
            }
        }
    }
    
    func deviceMove() async {
        isThinking.toggle()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Find the best move using strategy
        if let bestMove = findBestMove() {
            if let matchingIndex = Move.all.firstIndex(where: {$0 == bestMove}) {
                makeMove(at: matchingIndex)
            }
        }
        
        isThinking.toggle()
    }
    
    // MARK: - AI Strategy Functions
    
    private func findBestMove() -> Int? {
        // Strategy priority:
        // 1. Win if possible
        // 2. Block opponent's winning move
        // 3. Take center (position 5)
        // 4. Take corners (1, 3, 7, 9)
        // 5. Take edges (2, 4, 6, 8)
        
        // 1. Check if AI can win
        if let winningMove = findWinningMove(for: player2) {
            return winningMove
        }
        
        // 2. Check if need to block opponent's win
        if let blockingMove = findWinningMove(for: player1) {
            return blockingMove
        }
        
        // 3. Take center if available
        if possibleMoves.contains(5) {
            return 5
        }
        
        // 4. Take corners
        let corners = [1, 3, 7, 9]
        for corner in corners {
            if possibleMoves.contains(corner) {
                return corner
            }
        }
        
        // 5. Take edges
        let edges = [2, 4, 6, 8]
        for edge in edges {
            if possibleMoves.contains(edge) {
                return edge
            }
        }
        
        // Fallback to random if nothing else works
        return possibleMoves.randomElement()
    }
    
    private func findWinningMove(for player: Player) -> Int? {
        // Check each winning combination to see if player has 2 positions
        // and the third position is available
        for winningCombo in Move.winningMoves {
            let playerPositions = winningCombo.filter { player.moves.contains($0) }
            
            // If player has 2 out of 3 positions in this winning combo
            if playerPositions.count == 2 {
                // Find the missing position
                let missingPosition = winningCombo.first { !player.moves.contains($0) }
                
                // Check if the missing position is available
                if let missingPos = missingPosition, possibleMoves.contains(missingPos) {
                    return missingPos
                }
            }
        }
        
        return nil
    }
}
