import SwiftUI

struct SquareView: View {
    @EnvironmentObject var game: GameService
    @EnvironmentObject var connectionManager: MPConnectionManager
    @State private var isPressed = false
    @State private var pieceScale: CGFloat = 0.0
    private let hapticManager = HapticManager.shared
    let index: Int
    
    var body: some View {
        Button {
            if !game.isThinking {
                // Play button press haptic
                hapticManager.playHaptic(HapticManager.Feedback.button)
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    pieceScale = 1.0
                }
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
                
                game.makeMove(at: index)
            }
            if game.gameType == .peer {
                let gameMove = MPGameMove(action: .move, playrName: connectionManager.myPeerId.displayName, index: index)
                connectionManager.send(gameMove: gameMove)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(game.gameBoard[index].player != nil ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(radius: isPressed ? 2 : 4)
                
                game.gameBoard[index].image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .scaleEffect(pieceScale)
                    .opacity(game.gameBoard[index].player != nil ? 1.0 : 0.0)
            }
        }
        .disabled(game.gameBoard[index].player != nil)
        .foregroundColor(.primary)
        .onAppear {
            if game.gameBoard[index].player != nil {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    pieceScale = 1.0
                }
            }
        }
        .onChange(of: game.gameBoard[index].player) { oldValue, newValue in
            if newValue != nil {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    pieceScale = 1.0
                }
            } else {
                pieceScale = 0.0
            }
        }
    }
}

struct SquareView_Previews: PreviewProvider {
    static var previews: some View {
        SquareView(index: 1)
            .environmentObject(GameService())
            .environmentObject(MPConnectionManager(yourName: "Sample"))
    }
}
