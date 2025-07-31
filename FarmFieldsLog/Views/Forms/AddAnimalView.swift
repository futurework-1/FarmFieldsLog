import SwiftUI

struct AddAnimalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    
    @State private var species = Animal.AnimalSpecies.chicken
    @State private var breed = ""
    @State private var name = ""
    @State private var count = 1
    @State private var age = ""
    @State private var healthStatus = Animal.HealthStatus.good
    @State private var lastVaccination: Date?
    @State private var nextVaccination: Date?
    @State private var notes = ""
    @State private var isHighProducer = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Animal Information")) {
                    Picker("Species", selection: $species) {
                        ForEach(Animal.AnimalSpecies.allCases, id: \.self) { species in
                            HStack {
                                Text(species.icon)
                                Text(species.rawValue)
                            }
                            .tag(species)
                        }
                    }
                    
                    TextField("Breed", text: $breed)
                    TextField("Name (Optional)", text: $name)
                    
                    Stepper("Count: \(count)", value: $count, in: 1...999)
                    TextField("Age", text: $age)
                }
                
                Section(header: Text("Health Status")) {
                    Picker("Health", selection: $healthStatus) {
                        ForEach(Animal.HealthStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 12, height: 12)
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                    
                    Toggle("High Producer", isOn: $isHighProducer)
                }
                
                Section(header: Text("Vaccination Records")) {
                    DatePicker(
                        "Last Vaccination",
                        selection: Binding(
                            get: { lastVaccination ?? Date() },
                            set: { lastVaccination = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .disabled(lastVaccination == nil)
                    
                    Toggle("Has been vaccinated", isOn: Binding(
                        get: { lastVaccination != nil },
                        set: { if !$0 { lastVaccination = nil; nextVaccination = nil } else { lastVaccination = Date() } }
                    ))
                    
                    if lastVaccination != nil {
                        DatePicker(
                            "Next Vaccination",
                            selection: Binding(
                                get: { nextVaccination ?? Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date() },
                                set: { nextVaccination = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .disabled(nextVaccination == nil)
                        
                        Toggle("Schedule next vaccination", isOn: Binding(
                            get: { nextVaccination != nil },
                            set: { if !$0 { nextVaccination = nil } else { nextVaccination = Calendar.current.date(byAdding: .month, value: 6, to: Date()) } }
                        ))
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Animal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAnimal()
                    }
                    .disabled(breed.isEmpty)
                }
            }
        }
    }
    
    private func saveAnimal() {
        let newAnimal = Animal(
            species: species,
            breed: breed,
            name: name.isEmpty ? nil : name,
            count: count,
            age: age,
            healthStatus: healthStatus,
            lastVaccination: lastVaccination,
            nextVaccination: nextVaccination,
            notes: notes,
            isHighProducer: isHighProducer
        )
        
        dataManager.addAnimal(newAnimal)
        dismiss()
    }
}

#Preview {
    AddAnimalView()
        .environmentObject(FarmDataManager.shared)
}