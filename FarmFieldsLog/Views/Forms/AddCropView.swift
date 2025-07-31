import SwiftUI

struct AddCropView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    
    @State private var name = ""
    @State private var variety = ""
    @State private var plantingArea = ""
    @State private var plantingDate = Date()
    @State private var expectedHarvestDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var currentStage = Crop.CropStage.planted
    @State private var status = Crop.CropStatus.healthy
    @State private var notes = ""
    @State private var unitOfMeasure = "kg"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Crop Information")) {
                    TextField("Crop Name", text: $name)
                    TextField("Variety", text: $variety)
                    TextField("Planting Area", text: $plantingArea)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Planting Date", selection: $plantingDate, displayedComponents: .date)
                    DatePicker("Expected Harvest", selection: $expectedHarvestDate, displayedComponents: .date)
                }
                
                Section(header: Text("Current Status")) {
                    Picker("Growth Stage", selection: $currentStage) {
                        ForEach(Crop.CropStage.allCases, id: \.self) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                    
                    Picker("Health Status", selection: $status) {
                        ForEach(Crop.CropStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 12, height: 12)
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Unit of Measure", text: $unitOfMeasure)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Crop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCrop()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCrop() {
        let newCrop = Crop(
            name: name,
            variety: variety,
            plantingArea: plantingArea,
            plantingDate: plantingDate,
            expectedHarvestDate: expectedHarvestDate,
            currentStage: currentStage,
            status: status,
            notes: notes,
            harvestAmount: 0,
            unitOfMeasure: unitOfMeasure
        )
        
        dataManager.addCrop(newCrop)
        dismiss()
    }
}

#Preview {
    AddCropView()
        .environmentObject(FarmDataManager.shared)
}