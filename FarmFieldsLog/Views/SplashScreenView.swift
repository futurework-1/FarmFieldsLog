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
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: opacity)
                
                Spacer()
                
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.7), value: opacity)
                    
                    Text(loadingText)
                        .font(.custom("Chango-Regular", size: 14))
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
        let loadingDuration = Double.random(in: 2.8 ... 5.8)
        let textChangeInterval = loadingDuration / Double(loadingTexts.count)
        
        for (index, text) in loadingTexts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * textChangeInterval) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadingText = text
                }
            }
        }
        
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
