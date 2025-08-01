import SwiftUI
struct ContentView: View {
    var body: some View {
        MainTabView()
            .environmentObject(FarmDataManager.shared)
    }
}
#Preview {
    ContentView()
        .environmentObject(FarmDataManager.shared)
}
