import SwiftUI

struct StartView: View {
    @EnvironmentObject var game: GameService
    @StateObject var connectionManager: MPConnectionManager
    @State private var gameType: GameType = .undetermined
    @AppStorage("yourName") var yourName = ""
    @State private var opponentName = ""
    @FocusState private var focus: Bool
    @State private var startGame = false
    @State private var changeName = false
    @State private var newName = ""
    @State private var titleOffset: CGFloat = -50
    @State private var titleOpacity: Double = 0
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    
    init(yourName: String) {
        self.yourName = yourName
        _connectionManager = StateObject(wrappedValue: MPConnectionManager(yourName: yourName))
    }
    
    var body: some View {
            VStack(spacing: 20) {
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                                contentOffset = 0
                                contentOpacity = 1
                            }
                        }
                    }
                
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Picker("Select Game", selection: $gameType) {
                            Text("Select Game Type").tag(GameType.undetermined)
                            Text("Two Sharing device").tag(GameType.single)
                            Text("Challenge your device").tag(GameType.bot)
                            Text("Challenge a friend").tag(GameType.peer)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.3), value: gameType)
                        
                        Text(gameType.description)
                            .padding()
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.3), value: gameType.description)
                    }
                    
                    VStack {
                        switch gameType {
                        case .single:
                            TextField("Opponent Name", text: $opponentName)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        case .bot:
                            EmptyView()
                        case .peer:
                            MPPeersView(startGame: $startGame)
                                .environmentObject(connectionManager)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        case .undetermined:
                            EmptyView()
                        }
                    }
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .focused($focus)
                    .frame(width: 350)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameType)
                    
                    if gameType != .peer {
                        VStack(spacing: 15) {
                            Button("🎮 Start Game") {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    game.setupGame(gameType: gameType, player1Name: yourName, player2Name: opponentName)
                                    focus = false
                                    startGame.toggle()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(
                                gameType == .undetermined ||
                                gameType == .single && opponentName.isEmpty
                            )
                            .scaleEffect(
                                gameType == .undetermined ||
                                gameType == .single && opponentName.isEmpty ? 0.9 : 1.0
                            )
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: gameType)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: opponentName)
                            
                            Image("LaunchScreen")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 10)
                            
                            VStack(spacing: 10) {
                                Text("Your paca name is \(yourName)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Button("✏️ Change my paca name") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        changeName.toggle()
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
                }
                .offset(y: contentOffset)
                .opacity(contentOpacity)
                
                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $startGame) {
                GameView()
                    .environmentObject(connectionManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
            .alert("Change Paca Name", isPresented: $changeName, actions: {
                TextField("New paca name", text: $newName)
                Button("OK") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        yourName = newName
                        newName = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newName = ""
                }
            }, message: {
                Text("Enter your new paca name. The change will take effect immediately.")
            })
            .inNavigationStack()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(yourName: "Sample")
            .environmentObject(GameService())
    }
}
