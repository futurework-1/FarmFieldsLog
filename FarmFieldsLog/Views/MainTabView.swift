import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = FarmDataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Контент текущей вкладки
            Group {
                switch selectedTab {
                case 0:
                    FarmboardView()
                case 1:
                    PlantingCycleView()
                case 2:
                    AnimalsProductionView()
                case 3:
                    StoragePlanningView()
                case 4:
                    SettingsView()
                default:
                    FarmboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Кастомный tab bar
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            hideTabBar()
        }
        .environmentObject(dataManager)
    }
    
    private func hideTabBar() {
        UITabBar.appearance().isHidden = true
    }
}

// Кастомный tab bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("tab_bar_bg")
                .resizable()
                .scaledToFit()
                .frame(height: 78)
            
            // Иконки
            HStack(spacing: 22) {
                ForEach(0..<5) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        TabIcon(
                            normalImage: "tab\(index)",
                            selectedImage: "tab\(index)yellow",
                            isSelected: selectedTab == index
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 0)
        }
    }
}

// Кастомная иконка для таб бара
struct TabIcon: View {
    let normalImage: String
    let selectedImage: String
    let isSelected: Bool
    
    var body: some View {
        Image(isSelected ? selectedImage : normalImage)
            .resizable()
            .scaledToFit()
            .frame(width: 36, height: 36)
    }
}

#Preview {
    MainTabView()
}
