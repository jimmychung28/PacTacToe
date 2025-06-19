import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
    @Environment(\.dismiss) var dismiss
    @State private var gameOverScale: CGFloat = 0.8
    @State private var titleOffset: CGFloat = -50
    @State private var titleOpacity: Double = 0
    @State private var showAlpacaAnimation = false
    @State private var alpacaAnimationType: AlpacaAnimationType = .entrance
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width > 768
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            
            if isIPad {
                iPadLayout(availableWidth: availableWidth, availableHeight: availableHeight)
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            game.reset()
            if game.gameType == .peer {
                connectionManager.setup(game: game)
            }
            
            // Show entrance animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlpacaAnimation = true
                alpacaAnimationType = .entrance
            }
        }
        .onChange(of: game.gameOver) { oldValue, newValue in
            if newValue {
                if game.possibleMoves.isEmpty {
                    // Tie game
                    alpacaAnimationType = .confused
                } else if game.currentPlayer.name == game.player1.name && game.gameType != .bot {
                    // Player 1 wins (not bot mode)
                    alpacaAnimationType = .celebration
                } else if game.currentPlayer.name == game.player2.name && game.gameType == .bot {
                    // Bot wins
                    alpacaAnimationType = .sad
                } else {
                    // Player 2 wins (peer mode) or Player 1 wins (bot mode)
                    alpacaAnimationType = .celebration
                }
                showAlpacaAnimation = true
            }
        }
        .overlay {
            if showAlpacaAnimation {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    AlpacaAnimationView(animationType: alpacaAnimationType)
                        .onAppear {
                            // Auto-hide animation after delay
                            let delay: Double = alpacaAnimationType == .thinking ? 0 : 3.0
                            if delay > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        showAlpacaAnimation = false
                                    }
                                }
                            }
                        }
                }
                .transition(.opacity)
            }
        }
        .inNavigationStack()
    }
    
    var iPhoneLayout: some View {
        VStack {
            Spacer(minLength: 10)
            Text("Pac-Tac-Toe 🦙")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
                .offset(y: titleOffset)
                .opacity(titleOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        titleOffset = 0
                        titleOpacity = 1
                    }
                }
            
            if [game.player1.isCurrent, game.player2.isCurrent].allSatisfy({ $0 == false }) {
                Text("Select a player to start")
                    .transition(.scale.combined(with: .opacity))
            }
            
            HStack(spacing: 20) {
                Button(game.player1.name) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        game.player1.isCurrent = true
                    }
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .start, playrName: game.player1.name, index: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(PlayerButtonStyle(player: game.player1))
                
                Button(game.player2.name) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        game.player2.isCurrent = true
                    }
                    if game.gameType == .bot {
                        Task {
                            await game.deviceMove()
                        }
                    }
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .start, playrName: game.player2.name, index: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(PlayerButtonStyle(player: game.player2))
            }
            .disabled(game.gameStarted)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: game.gameStarted)
            
            gameBoard(availableWidth: UIScreen.main.bounds.width)
            .overlay {
                if game.isThinking {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                        
                        AlpacaAnimationView(animationType: .thinking)
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 15)
                        )
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .disabled(game.boardDisabled ||
                      game.gameType == .peer &&
                      connectionManager.myPeerId.displayName != game.currentPlayer.name)
            
            VStack(spacing: 15) {
                if game.gameOver {
                    VStack(spacing: 10) {
                        Text("Game Over!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if game.possibleMoves.isEmpty {
                            Text("🤝 It's a tie!")
                                .font(.title2)
                                .foregroundColor(.orange)
                        } else {
                            Text("🏆 \(game.currentPlayer.name) wins!")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        
                        Button("🎮 New Game") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                game.reset()
                            }
                            if game.gameType == .peer {
                                let gameMove = MPGameMove(action: .reset, playrName: nil, index: nil)
                                connectionManager.send(gameMove: gameMove)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .scaleEffect(gameOverScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                gameOverScale = 1.1
                            }
                        }
                        .onDisappear {
                            gameOverScale = 0.8
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom)),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: game.gameOver)
            
            Spacer(minLength: 20)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dismiss()
                    }
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .end, playrName: nil, index: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    func iPadLayout(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        HStack(spacing: 40) {
            // Left side - Game info and controls
            VStack(spacing: 30) {
                Text("Pac-Tac-Toe 🦙")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            titleOffset = 0
                            titleOpacity = 1
                        }
                    }
                
                if [game.player1.isCurrent, game.player2.isCurrent].allSatisfy({ $0 == false }) {
                    Text("Select a player to start")
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                }
                
                VStack(spacing: 20) {
                    Button(game.player1.name) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            game.player1.isCurrent = true
                        }
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .start, playrName: game.player1.name, index: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(iPadPlayerButtonStyle(player: game.player1))
                    
                    Button(game.player2.name) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            game.player2.isCurrent = true
                        }
                        if game.gameType == .bot {
                            Task {
                                await game.deviceMove()
                            }
                        }
                        if game.gameType == .peer {
                            let gameMove = MPGameMove(action: .start, playrName: game.player2.name, index: nil)
                            connectionManager.send(gameMove: gameMove)
                        }
                    }
                    .buttonStyle(iPadPlayerButtonStyle(player: game.player2))
                }
                .disabled(game.gameStarted)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: game.gameStarted)
                
                // Game over section
                if game.gameOver {
                    VStack(spacing: 15) {
                        Text("Game Over!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if game.possibleMoves.isEmpty {
                            Text("🤝 It's a tie!")
                                .font(.title)
                                .foregroundColor(.orange)
                        } else {
                            Text("🏆 \(game.currentPlayer.name) wins!")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        
                        Button("🎮 New Game") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                game.reset()
                            }
                            if game.gameType == .peer {
                                let gameMove = MPGameMove(action: .reset, playrName: nil, index: nil)
                                connectionManager.send(gameMove: gameMove)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .scaleEffect(gameOverScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                gameOverScale = 1.1
                            }
                        }
                        .onDisappear {
                            gameOverScale = 0.8
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 15)
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom)),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                Spacer()
            }
            .frame(maxWidth: 400)
            .padding(.leading, 40)
            
            Spacer()
            
            // Right side - Game board
            VStack {
                Spacer(minLength: 40)
                iPadGameBoard(availableWidth: availableWidth, availableHeight: availableHeight)
                    .disabled(game.boardDisabled ||
                              game.gameType == .peer &&
                              connectionManager.myPeerId.displayName != game.currentPlayer.name)
                Spacer()
            }
            .padding(.trailing, 40)
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: game.gameOver)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dismiss()
                    }
                    if game.gameType == .peer {
                        let gameMove = MPGameMove(action: .end, playrName: nil, index: nil)
                        connectionManager.send(gameMove: gameMove)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    func gameBoard(availableWidth: CGFloat) -> some View {
        let padding: CGFloat = 32 // Total horizontal padding from .padding()
        let spacing: CGFloat = 8
        let availableBoardWidth = availableWidth - padding
        let maxSquareSize = min((availableBoardWidth - 2 * spacing) / 3, 100)
        let squareSize = max(maxSquareSize, 70) // Minimum 70x70 for phones
        
        return VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(0...2, id: \.self) { index in
                    SquareView(index: index, squareSize: squareSize)
                }
            }
            HStack(spacing: spacing) {
                ForEach(3...5, id: \.self) { index in
                    SquareView(index: index, squareSize: squareSize)
                }
            }
            HStack(spacing: spacing) {
                ForEach(6...8, id: \.self) { index in
                    SquareView(index: index, squareSize: squareSize)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.05))
                .shadow(radius: 10)
        )
        .overlay {
            if game.isThinking {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    VStack(spacing: 15) {
                        Text("🤔 Thinking...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 15)
                    )
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    func iPadGameBoard(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        let leftPanelWidth: CGFloat = 400
        let horizontalPadding: CGFloat = 80 // 40 each side
        let spacing: CGFloat = 40
        let boardSpacing: CGFloat = 15
        let boardPadding: CGFloat = 30
        
        let availableBoardWidth = availableWidth - leftPanelWidth - horizontalPadding - spacing
        let maxSquareSize = min((availableBoardWidth - 2 * boardSpacing - 2 * boardPadding) / 3, 140)
        let squareSize = max(maxSquareSize, 80) // Minimum 80x80
        
        return VStack(spacing: boardSpacing) {
            HStack(spacing: boardSpacing) {
                ForEach(0...2, id: \.self) { index in
                    iPadSquareView(index: index, squareSize: squareSize)
                }
            }
            HStack(spacing: boardSpacing) {
                ForEach(3...5, id: \.self) { index in
                    iPadSquareView(index: index, squareSize: squareSize)
                }
            }
            HStack(spacing: boardSpacing) {
                ForEach(6...8, id: \.self) { index in
                    iPadSquareView(index: index, squareSize: squareSize)
                }
            }
        }
        .padding(boardPadding)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.05))
                .shadow(radius: 15)
        )
        .overlay {
            if game.isThinking {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                    
                    AlpacaAnimationView(animationType: .thinking)
                    .padding(boardPadding + 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 20)
                    )
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    @ViewBuilder
    func iPadSquareView(index: Int, squareSize: CGFloat) -> some View {
        Button {
            if !game.isThinking {
                game.makeMove(at: index)
            }
            if game.gameType == .peer {
                let gameMove = MPGameMove(action: .move, playrName: connectionManager.myPeerId.displayName, index: index)
                connectionManager.send(gameMove: gameMove)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: min(squareSize * 0.14, 20))
                    .fill(game.gameBoard[index].player != nil ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: squareSize, height: squareSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: min(squareSize * 0.14, 20))
                            .stroke(Color.blue.opacity(0.3), lineWidth: max(squareSize * 0.02, 2))
                    )
                    .shadow(radius: max(squareSize * 0.06, 4))
                
                game.gameBoard[index].image
                    .resizable()
                    .frame(width: squareSize * 0.64, height: squareSize * 0.64)
                    .opacity(game.gameBoard[index].player != nil ? 1.0 : 0.0)
                    .scaleEffect(game.gameBoard[index].player != nil ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: game.gameBoard[index].player != nil)
            }
        }
        .disabled(game.gameBoard[index].player != nil)
        .foregroundColor(.primary)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameService())
            .environmentObject(MPConnectionManager(yourName: "Sample"))
    }
}

struct PlayerButtonStyle: ButtonStyle {
    let player: Player
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, *) {
            configuration.label
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(player.isCurrent ? 
                              LinearGradient(colors: [Color.green, Color.green.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                             )
                        .shadow(color: player.isCurrent ? Color.green.opacity(0.3) : Color.clear, radius: 8)
                )
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .brightness(configuration.isPressed ? -0.1 : 0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: player.isCurrent)
        } else {
            // Fallback on earlier versions
        }
    }
}

struct iPadPlayerButtonStyle: ButtonStyle {
    let player: Player
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, *) {
            configuration.label
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .frame(minWidth: 280)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(player.isCurrent ? 
                              LinearGradient(colors: [Color.green, Color.green.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                             )
                        .shadow(color: player.isCurrent ? Color.green.opacity(0.3) : Color.clear, radius: 12)
                )
                .foregroundColor(.white)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .brightness(configuration.isPressed ? -0.1 : 0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: player.isCurrent)
        } else {
            // Fallback on earlier versions
        }
    }
}
