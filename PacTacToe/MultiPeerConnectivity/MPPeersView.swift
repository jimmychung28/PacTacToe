import SwiftUI

struct MPPeersView: View {
    
    @EnvironmentObject var connectionManager: MPConnectionManager
    @EnvironmentObject var game: GameService
    @Binding var startGame: Bool
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width > 768
            
            VStack(spacing: isIPad ? 30 : 20) {
                Text("Available Players")
                    .font(isIPad ? .system(size: 28, weight: .semibold) : .headline)
                    .foregroundColor(.primary)
                
                if connectionManager.availablePeers.isEmpty {
                    VStack(spacing: isIPad ? 20 : 15) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: isIPad ? 60 : 40))
                            .foregroundColor(.secondary)
                        
                        Text("Looking for nearby players...")
                            .font(isIPad ? .title2 : .body)
                            .foregroundColor(.secondary)
                        
                        Text("Make sure other players have the app open and are in peer-to-peer mode.")
                            .font(isIPad ? .body : .caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(connectionManager.availablePeers, id: \.self) { peer in
                        HStack(spacing: isIPad ? 20 : 10) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(peer.displayName)
                                    .font(isIPad ? .title2 : .headline)
                                    .foregroundColor(.primary)
                                
                                Text("Tap to invite")
                                    .font(isIPad ? .body : .caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Invite") {
                                game.gameType = .peer
                                connectionManager.nearbyServiceBrowser.invitePeer(peer, to: connectionManager.session, withContext: nil, timeout: 30)
                                game.player1.name = connectionManager.myPeerId.displayName
                                game.player2.name = peer.displayName
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(isIPad ? .large : .regular)
                        }
                        .padding(isIPad ? 20 : 10)
                    }
                    .listStyle(.plain)
                }
            }
            .padding(isIPad ? 30 : 20)
        }
        .alert("Received Invitation from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")",
               isPresented: $connectionManager.receivedInvite) {
            Button("Accept") {
                if let invitationHandler = connectionManager.invitationHandler {
                    invitationHandler(true, connectionManager.session)
                    game.player1.name = connectionManager.receivedInviteFrom?.displayName ?? "Unknown"
                    game.player2.name = connectionManager.myPeerId.displayName
                    game.gameType = .peer
                }
            }
            Button("Reject") {
                if let invitationHandler = connectionManager.invitationHandler {
                    invitationHandler(false, nil)
                }
            }
        }
        .onAppear {
            connectionManager.isAvailableToPlay = true
            connectionManager.startBrowsing()
        }
        .onDisappear {
            connectionManager.stopBrowsing()
            connectionManager.stopAdvertising()
            connectionManager.isAvailableToPlay = false
        }
        .onChange(of: connectionManager.paired) { oldValue, newValue in
            startGame = newValue
        }
    }
}

struct MPPeersView_Previews: PreviewProvider {
    static var previews: some View {
        MPPeersView(startGame: .constant(false))
            .environmentObject(MPConnectionManager(yourName: "Sample"))
            .environmentObject(GameService())
    }
}
