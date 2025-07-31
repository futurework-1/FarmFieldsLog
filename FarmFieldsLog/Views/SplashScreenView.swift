import SwiftUI

struct SplashScreenView: View {
    @State private var isLoading = true
    @State private var scale = 0.5
    @State private var opacity = 0.0
    @State private var loadingText = "Loading..."
    
    private let loadingTexts = [
        "Preparing your farm...",
        "Loading crops data...",
        "Checking animals...",
        "Updating storage...",
        "Almost ready..."
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.2, green: 0.3, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background image overlay
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.3)
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon/Logo
                VStack(spacing: 20) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0), value: scale)
                        .animation(.easeInOut(duration: 1.0), value: opacity)
                    
                    // App Title
                    Text("FARM FIELDS LOG")
                        .font(.custom("Chango-Regular", size: 32))
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.3), value: opacity)
                    
                    Text("Your Digital Farm Manager")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.5), value: opacity)
                }
                
                Spacer()
                
                // Loading indicator and text
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.7), value: opacity)
                    
                    Text(loadingText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.9), value: opacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimations()
            startLoadingProcess()
        }
        .fullScreenCover(isPresented: .constant(!isLoading)) {
            MainTabView()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            scale = 1.0
            opacity = 1.0
        }
    }
    
    private func startLoadingProcess() {
        // Randomize loading time between 3-6 seconds
        let loadingDuration = Double.random(in: 3.0...6.0)
        let textChangeInterval = loadingDuration / Double(loadingTexts.count)
        
        // Change loading text progressively
        for (index, text) in loadingTexts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * textChangeInterval) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadingText = text
                }
            }
        }
        
        // Complete loading after the random duration
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDuration) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isLoading = false
            }
        }
    }
}

#Preview {
    SplashScreenView()
}