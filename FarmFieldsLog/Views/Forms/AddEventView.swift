import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var eventType = FarmEvent.EventType.other
    @State private var reminderDate: Date?
    @State private var hasReminder = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Event Type")) {
                    Picker("Type", selection: $eventType) {
                        ForEach(FarmEvent.EventType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Event Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Set Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker(
                            "Reminder Date",
                            selection: Binding(
                                get: { reminderDate ?? Calendar.current.date(byAdding: .hour, value: -1, to: date) ?? date },
                                set: { reminderDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onChange(of: hasReminder) { newValue in
            if newValue && reminderDate == nil {
                reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: date)
            } else if !newValue {
                reminderDate = nil
            }
        }
    }
    
    private func saveEvent() {
        let newEvent = FarmEvent(
            title: title,
            description: description,
            date: date,
            eventType: eventType,
            isCompleted: false,
            reminderDate: hasReminder ? reminderDate : nil,
            relatedAnimalId: nil,
            relatedCropId: nil
        )
        
        dataManager.addEvent(newEvent)
        dismiss()
    }
}

#Preview {
    AddEventView()
        .environmentObject(FarmDataManager.shared)
}