import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingClearDataAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Units Section
                Section(header: Text("Units of Measurement")) {
                    Picker("Weight Unit", selection: $dataManager.settings.weightUnit) {
                        ForEach(AppSettings.WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    
                    Picker("Volume Unit", selection: $dataManager.settings.volumeUnit) {
                        ForEach(AppSettings.VolumeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    
                    Picker("Area Unit", selection: $dataManager.settings.areaUnit) {
                        ForEach(AppSettings.AreaUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $dataManager.settings.enableNotifications)
                    
                    if dataManager.settings.enableNotifications {
                        Toggle("Task Reminders", isOn: $dataManager.settings.enableTaskReminders)
                        Toggle("Watering Reminders", isOn: $dataManager.settings.enableWateringReminders)
                        Toggle("Vaccination Reminders", isOn: $dataManager.settings.enableVaccinationReminders)
                        
                        DatePicker(
                            "Reminder Time",
                            selection: $dataManager.settings.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                // Farm Statistics Section
                Section(header: Text("Farm Statistics")) {
                    StatisticRow(
                        title: "Total Tasks",
                        value: "\(dataManager.tasks.count)",
                        icon: "checkmark.circle"
                    )
                    
                    StatisticRow(
                        title: "Total Crops",
                        value: "\(dataManager.crops.count)",
                        icon: "leaf"
                    )
                    
                    StatisticRow(
                        title: "Total Animals",
                        value: "\(dataManager.animals.reduce(0) { $0 + $1.count })",
                        icon: "pawprint"
                    )
                    
                    StatisticRow(
                        title: "Storage Items",
                        value: "\(dataManager.storageItems.count)",
                        icon: "cube.box"
                    )
                    
                    StatisticRow(
                        title: "Production Records",
                        value: "\(dataManager.productionRecords.count)",
                        icon: "chart.bar"
                    )
                }
                
                // Data Management Section
                Section(header: Text("Data Management")) {
                    Button("Export Data") {
                        // TODO: Implement data export
                    }
                    .foregroundColor(.blue)
                    
                    Button("Import Data") {
                        // TODO: Implement data import
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data") {
                        showingClearDataAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                // App Information Section
                Section(header: Text("App Information")) {
                    Button("About Farm Fields Log") {
                        showingAbout = true
                    }
                    .foregroundColor(.blue)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Open privacy policy
                    }
                    .foregroundColor(.blue)
                    
                    Button("Terms of Service") {
                        // TODO: Open terms of service
                    }
                    .foregroundColor(.blue)
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    Button("Contact Support") {
                        // TODO: Open support contact
                    }
                    .foregroundColor(.blue)
                    
                    Button("Rate App") {
                        // TODO: Open app store rating
                    }
                    .foregroundColor(.blue)
                    
                    Button("Share App") {
                        // TODO: Implement share functionality
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                dataManager.clearAllData()
            }
        } message: {
            Text("This will permanently delete all your farm data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .onChange(of: dataManager.settings) { _ in
            dataManager.saveData()
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon and Title
                    VStack(spacing: 15) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("FARM FIELDS LOG")
                            .font(.custom("Chango-Regular", size: 28))
                            .foregroundColor(.primary)
                        
                        Text("Your Digital Farm Manager")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Farm Fields Log is your comprehensive digital farm management solution. Track your crops, manage livestock, monitor production, and plan seasonal activities all in one place.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "chart.bar.fill", text: "Farm dashboard with productivity overview")
                            FeatureRow(icon: "leaf.fill", text: "Crop planting and harvest tracking")
                            FeatureRow(icon: "pawprint.fill", text: "Animal management and production records")
                            FeatureRow(icon: "cube.box.fill", text: "Storage and inventory management")
                            FeatureRow(icon: "calendar", text: "Seasonal planning and event scheduling")
                            FeatureRow(icon: "bell.fill", text: "Smart reminders and notifications")
                        }
                    }
                    
                    // Developer Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Developer")
                            .font(.headline)
                        
                        Text("Built with ❤️ for farmers everywhere")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(FarmDataManager.shared)
}