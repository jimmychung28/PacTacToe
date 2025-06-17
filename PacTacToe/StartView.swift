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
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    
    init(yourName: String) {
        self.yourName = yourName
        _connectionManager = StateObject(wrappedValue: MPConnectionManager(yourName: yourName))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width > 768
            
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
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
    
    var iPhoneLayout: some View {
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
                    gameTypeSelector
                    
                    gameTypeContent
                    
                    if gameType != .peer {
                        gameControls
                    }
                }
                .offset(y: contentOffset)
                .opacity(contentOpacity)
                
                Spacer()
            }
            .padding()
    }
    
    var iPadLayout: some View {
        VStack(spacing: 40) {
            Text("Pac-Tac-Toe 🦙")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.top, 40)
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
            
            HStack(spacing: 60) {
                // Left side - Game selection
                VStack(spacing: 30) {
                    iPadGameTypeSelector
                    iPadGameTypeContent
                }
                .frame(maxWidth: 500)
                
                // Right side - Game controls and info
                VStack(spacing: 30) {
                    if gameType != .peer {
                        iPadGameControls
                    }
                }
                .frame(maxWidth: 400)
            }
            .offset(y: contentOffset)
            .opacity(contentOpacity)
            
            Spacer()
        }
        .padding(.horizontal, 60)
    }
    
    var gameTypeSelector: some View {
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
    }
    
    var iPadGameTypeSelector: some View {
        VStack(spacing: 25) {
            Text("Choose Your Game Mode")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                ForEach([GameType.single, GameType.bot, GameType.peer], id: \.self) { type in
                    Button(action: {
                        soundManager.playSound(SoundManager.SoundEffect.button)
                        hapticManager.playHaptic(HapticManager.Feedback.button)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            gameType = type
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(gameTypeName(for: type))
                                    .font(.system(size: 20, weight: .semibold))
                                Text(type.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            if gameType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(gameType == type ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                .stroke(gameType == type ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    var gameTypeContent: some View {
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
    }
    
    var iPadGameTypeContent: some View {
        VStack {
            switch gameType {
            case .single:
                VStack(spacing: 15) {
                    Text("Enter Opponent's Name")
                        .font(.system(size: 20, weight: .medium))
                    TextField("Opponent Name", text: $opponentName)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 18))
                        .padding(.horizontal)
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            case .bot:
                VStack(spacing: 15) {
                    Text("🤖 Ready to Challenge the AI?")
                        .font(.system(size: 20, weight: .medium))
                    Text("The AI uses advanced strategy to provide a challenging experience!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            case .peer:
                MPPeersView(startGame: $startGame)
                    .environmentObject(connectionManager)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            case .undetermined:
                Text("Please select a game mode above")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameType)
    }
    
    var gameControls: some View {
        VStack(spacing: 15) {
            Button("🎮 Start Game") {
                soundManager.playSound(SoundManager.SoundEffect.button)
                hapticManager.playHaptic(HapticManager.Feedback.button)
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
                    soundManager.playSound(SoundManager.SoundEffect.button)
                    hapticManager.playHaptic(HapticManager.Feedback.button)
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
    
    var iPadGameControls: some View {
        VStack(spacing: 30) {
            Button("🎮 Start Game") {
                soundManager.playSound(SoundManager.SoundEffect.button)
                hapticManager.playHaptic(HapticManager.Feedback.button)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    game.setupGame(gameType: gameType, player1Name: yourName, player2Name: opponentName)
                    focus = false
                    startGame.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .font(.system(size: 20, weight: .semibold))
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
            
            VStack(spacing: 20) {
                Image("LaunchScreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 15)
                
                VStack(spacing: 15) {
                    Text("Your paca name is \(yourName)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Button("✏️ Change my paca name") {
                        soundManager.playSound(SoundManager.SoundEffect.button)
                        hapticManager.playHaptic(HapticManager.Feedback.button)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            changeName.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
    
    private func gameTypeName(for type: GameType) -> String {
        switch type {
        case .single:
            return "Two Sharing Device"
        case .bot:
            return "Challenge Your Device"
        case .peer:
            return "Challenge a Friend"
        case .undetermined:
            return "Select Game Type"
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(yourName: "Sample")
            .environmentObject(GameService())
    }
}
