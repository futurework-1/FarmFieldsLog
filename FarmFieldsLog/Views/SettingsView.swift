import SwiftUI
import UserNotifications
struct SettingsView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingClearDataAlert = false
    @State private var showingUnitSettings = false
    @State private var showingAbout = false
    @State private var showingSupport = false
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                Image("settings_text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 164)
                Spacer()
                VStack(spacing: 8) {
                    GameButton(
                        title: "UNIT SETTINGS",
                        showArrow: true,
                        action: {
                            showingUnitSettings = true
                        }
                    )
                    NotificationToggleButton(
                        isEnabled: $dataManager.settings.enableNotifications,
                        dataManager: dataManager
                    )
                    JournalClearButton {
                        showingClearDataAlert = true
                    }
                    GameButton(
                        title: "ABOUT THE APP",
                        showArrow: true,
                        action: {
                            showingAbout = true
                        }
                    )
                    GameButton(
                        title: "SUPPORT",
                        showArrow: true,
                        action: {
                            showingSupport = true
                        }
                    )
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 200)
            }
        }
        .overlay(
            Group {
                if showingUnitSettings {
                    UnitSettingsOverlay(
                        isPresented: $showingUnitSettings,
                        dataManager: dataManager
                    )
                }
            }
        )
        .overlay(
            Group {
                if showingClearDataAlert {
                    DeleteConfirmationDialog(
                        isPresented: $showingClearDataAlert,
                        onDelete: {
                            dataManager.clearAllData()
                        }
                    )
                }
            }
        )
        .onChange(of: dataManager.settings) { _ in
            dataManager.saveData()
        }
    }
}
struct GameButton: View {
    let title: String
    let showArrow: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("field")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 340)
            HStack {
                Text(title)
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                Spacer()
                if showArrow {
                    Image("btn_right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 30)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
        }
    }
}
struct NotificationToggleButton: View {
    @Binding var isEnabled: Bool
    let dataManager: FarmDataManager
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
        HStack {
            Text("NOTIFICATION")
                .font(.custom("Chango-Regular", size: 18))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
            Spacer()
            Button(action: {
                if !isEnabled {
                    requestNotificationPermission { granted in
                        DispatchQueue.main.async {
                            if granted {
                                isEnabled = true
                                dataManager.saveData()
                            } else {
                            }
                        }
                    }
                } else {
                    isEnabled = false
                    dataManager.saveData()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isEnabled ? Color.yellow : Color.gray.opacity(0.5))
                        .frame(width: 60, height: 32)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .offset(x: isEnabled ? 14 : -14)
                        .animation(.easeInOut(duration: 0.2), value: isEnabled)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
    }
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
            }
            completion(granted)
        }
    }
}
struct JournalClearButton: View {
    let action: () -> Void
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
        HStack {
            Text("JOURNAL")
                .font(.custom("Chango-Regular", size: 18))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
            Spacer()
            Button(action: action) {
                Text("CLEAR")
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.red)
                    .padding(.horizontal, 1)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
    }
}
struct DeleteConfirmationDialog: View {
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            ZStack {
                Image("window_delete")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 197)
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 6) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image("btn_cancel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 129)
                    }
                    Button(action: {
                        onDelete()
                        isPresented = false
                    }) {
                        Image("btn_delete")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 129)
                    }
                }
            }
            .frame(width: 330, height: 160)
            }
        }
    }
}
struct UnitSettingsOverlay: View {
    @Binding var isPresented: Bool
    let dataManager: FarmDataManager
    @State private var selectedUnit: AppSettings.PrimaryUnit = .kilograms
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image("btn_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Image("unit_settings_text")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                    Image("btn_back")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 10)
                Spacer()
                VStack(spacing: 8) {
                    ForEach(AppSettings.PrimaryUnit.allCases, id: \.self) { unit in
                        UnitOverlayButton(
                            title: unit.rawValue,
                            isSelected: selectedUnit == unit,
                            action: {
                                selectedUnit = unit
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
                Button(action: {
                    dataManager.settings.selectedPrimaryUnit = selectedUnit
                    switch selectedUnit {
                    case .kilograms:
                        dataManager.settings.weightUnit = .kilograms
                    case .liters:
                        dataManager.settings.volumeUnit = .liters
                    case .pieces:
                        dataManager.settings.areaUnit = .squareMeters
                    }
                    dataManager.saveData()
                    isPresented = false
                }) {
                    Image("btn_save")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                }
                .padding(.bottom, 200)
            }
        }
        .onAppear {
            selectedUnit = dataManager.settings.selectedPrimaryUnit
        }
    }
}
struct UnitOverlayButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(isSelected ? "field_selected" : "field")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330)
                HStack {
                    Text(title)
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("btn_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding()
                VStack(spacing: 20) {
                    Text("FARM FIELDS LOG")
                        .font(.custom("Chango-Regular", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Text("Version 1.0.0")
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    Text("Your Digital Farm Manager")
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("btn_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding()
                VStack(spacing: 20) {
                    Text("SUPPORT")
                        .font(.custom("Chango-Regular", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Text("Contact us for help and support")
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    SettingsView()
        .environmentObject(FarmDataManager.shared)
}
