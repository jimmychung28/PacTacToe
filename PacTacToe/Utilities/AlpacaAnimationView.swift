import SwiftUI

struct AlpacaAnimationView: View {
    let animationType: AlpacaAnimationType
    @State private var isAnimating = false
    @State private var bounceOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            switch animationType {
            case .celebration:
                celebrationAlpaca
            case .thinking:
                thinkingAlpaca
            case .entrance:
                entranceAlpaca
            case .sad:
                sadAlpaca
            case .confused:
                confusedAlpaca
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private var celebrationAlpaca: some View {
        VStack(spacing: 10) {
            Text("🦙")
                .font(.system(size: 80))
                .scaleEffect(scaleEffect)
                .rotationEffect(.degrees(rotationAngle))
                .offset(y: bounceOffset)
            
            Text("¡Alpaca Victory!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .opacity(opacity)
        }
    }
    
    private var thinkingAlpaca: some View {
        VStack(spacing: 15) {
            HStack(spacing: 5) {
                Text("🦙")
                    .font(.system(size: 60))
                    .scaleEffect(scaleEffect)
                
                VStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.5 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
            }
            
            Text("Alpaca is thinking...")
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
    
    private var entranceAlpaca: some View {
        VStack(spacing: 10) {
            Text("🦙")
                .font(.system(size: 100))
                .scaleEffect(scaleEffect)
                .opacity(opacity)
            
            Text("Welcome to Pac-Tac-Toe!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .opacity(opacity)
        }
    }
    
    private var sadAlpaca: some View {
        VStack(spacing: 10) {
            Text("🦙")
                .font(.system(size: 70))
                .scaleEffect(scaleEffect)
                .offset(y: bounceOffset)
            
            Text("Better luck next time!")
                .font(.headline)
                .foregroundColor(.orange)
                .opacity(opacity)
        }
    }
    
    private var confusedAlpaca: some View {
        VStack(spacing: 10) {
            Text("🦙")
                .font(.system(size: 70))
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(scaleEffect)
            
            Text("It's a draw!")
                .font(.headline)
                .foregroundColor(.purple)
                .opacity(opacity)
        }
    }
    
    private func startAnimation() {
        switch animationType {
        case .celebration:
            celebrationAnimation()
        case .thinking:
            thinkingAnimation()
        case .entrance:
            entranceAnimation()
        case .sad:
            sadAnimation()
        case .confused:
            confusedAnimation()
        }
    }
    
    private func celebrationAnimation() {
        withAnimation(.easeInOut(duration: 0.3).repeatCount(6, autoreverses: true)) {
            bounceOffset = -20
        }
        
        withAnimation(.easeInOut(duration: 0.5).repeatCount(4, autoreverses: true)) {
            rotationAngle = 15
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).repeatCount(3, autoreverses: true)) {
            scaleEffect = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 0
            }
        }
    }
    
    private func thinkingAnimation() {
        isAnimating = true
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            scaleEffect = 1.1
        }
    }
    
    private func entranceAnimation() {
        scaleEffect = 0
        opacity = 0
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            scaleEffect = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.5)) {
            opacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 0
            }
        }
    }
    
    private func sadAnimation() {
        withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
            bounceOffset = 10
        }
        
        withAnimation(.easeInOut(duration: 0.3).repeatCount(4, autoreverses: true)) {
            scaleEffect = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 0
            }
        }
    }
    
    private func confusedAnimation() {
        withAnimation(.easeInOut(duration: 0.4).repeatCount(6, autoreverses: true)) {
            rotationAngle = 10
        }
        
        withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
            scaleEffect = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 0
            }
        }
    }
}

enum AlpacaAnimationType {
    case celebration
    case thinking
    case entrance
    case sad
    case confused
}

struct AlpacaAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            AlpacaAnimationView(animationType: .celebration)
            AlpacaAnimationView(animationType: .thinking)
            AlpacaAnimationView(animationType: .entrance)
        }
        .padding()
    }
}