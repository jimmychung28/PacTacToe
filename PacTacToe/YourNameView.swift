import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    @State private var titleOffset: CGFloat = -50
    @State private var titleOpacity: Double = 0
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 25) {
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            imageScale = 1.0
                        }
                    }
                }
            
            VStack(spacing: 20) {
                Text("This is the paca name that will be associated with this device.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 15) {
                    TextField("Your Paca Name", text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("🎯 Set Name") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            yourName = userName
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userName.isEmpty)
                    .scaleEffect(userName.isEmpty ? 0.9 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: userName.isEmpty)
                }
                
                Image("LaunchScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 15)
                    .scaleEffect(imageScale)
                
                Spacer()
                    .frame(width: 0.0)
            }
            .offset(y: contentOffset)
            .opacity(contentOpacity)
        }
        .padding()
        .inNavigationStack()
    }
}

struct YourNameView_Previews: PreviewProvider {
    static var previews: some View {
        YourNameView()
    }
}
