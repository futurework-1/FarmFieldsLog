import SwiftUI

struct PlantingCycleView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingAddCrop = false
    @State private var selectedCrop: Crop?
    @State private var searchText = ""
    @State private var selectedStageFilter: Crop.CropStage?
    
    var filteredCrops: [Crop] {
        var crops = dataManager.crops
        
        if !searchText.isEmpty {
            crops = crops.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.variety.localizedCaseInsensitiveContains(searchText) ||
                $0.plantingArea.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let stageFilter = selectedStageFilter {
            crops = crops.filter { $0.currentStage == stageFilter }
        }
        
        return crops.sorted { $0.plantingDate > $1.plantingDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedStageFilter == nil
                            ) {
                                selectedStageFilter = nil
                            }
                            
                            ForEach(Crop.CropStage.allCases, id: \.self) { stage in
                                FilterChip(
                                    title: stage.rawValue,
                                    isSelected: selectedStageFilter == stage
                                ) {
                                    selectedStageFilter = stage == selectedStageFilter ? nil : stage
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
                
                // Crops List
                if filteredCrops.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "leaf",
                        title: "No Crops Yet",
                        subtitle: searchText.isEmpty ? "Start by adding your first crop" : "No crops match your search",
                        buttonTitle: "Add Crop"
                    ) {
                        showingAddCrop = true
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredCrops) { crop in
                            CropRowView(crop: crop) {
                                selectedCrop = crop
                            }
                        }
                        .onDelete(perform: deleteCrops)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Planting Cycle")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCrop = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCrop) {
            AddCropView()
        }
        .sheet(item: $selectedCrop) { crop in
            CropDetailView(crop: crop)
        }
    }
    
    private func deleteCrops(at offsets: IndexSet) {
        dataManager.deleteCrop(at: offsets)
    }
}

struct CropRowView: View {
    let crop: Crop
    let onTap: () -> Void
    
    var daysUntilHarvest: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status Indicator
                VStack {
                    Circle()
                        .fill(crop.status.color)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(crop.status.color.opacity(0.3))
                        .frame(width: 2)
                }
                .frame(height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(crop.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(crop.currentStage.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Text(crop.variety)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(crop.plantingArea)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if daysUntilHarvest > 0 {
                            Text("Harvest in \(daysUntilHarvest) days")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else if daysUntilHarvest == 0 {
                            Text("Ready to harvest!")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        } else {
                            Text("Overdue by \(-daysUntilHarvest) days")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct CropDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    @State var crop: Crop
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(crop.name)
                                    .font(.custom("Chango-Regular", size: 24))
                                
                                Text(crop.variety)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(crop.status.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.white)
                                )
                        }
                        
                        HStack {
                            InfoPill(title: "Stage", value: crop.currentStage.rawValue, color: .blue)
                            InfoPill(title: "Status", value: crop.status.rawValue, color: crop.status.color)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Timeline Card
                    TimelineCard(crop: crop)
                    
                    // Details Card
                    DetailsCard(crop: crop)
                    
                    if !crop.notes.isEmpty {
                        NotesCard(notes: crop.notes)
                    }
                }
                .padding()
            }
            .navigationTitle("Crop Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditCropView(crop: $crop)
        }
    }
}

// Supporting Views for PlantingCycleView
struct TimelineCard: View {
    let crop: Crop
    
    var daysPlanted: Int {
        Calendar.current.dateComponents([.day], from: crop.plantingDate, to: Date()).day ?? 0
    }
    
    var daysUntilHarvest: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Planted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(daysPlanted) days ago")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(crop.plantingDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Expected Harvest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if daysUntilHarvest > 0 {
                        Text("In \(daysUntilHarvest) days")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    } else if daysUntilHarvest == 0 {
                        Text("Today!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    } else {
                        Text("\(-daysUntilHarvest) days overdue")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    
                    Text(crop.expectedHarvestDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DetailsCard: View {
    let crop: Crop
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(title: "Planting Area", value: crop.plantingArea)
                DetailRow(title: "Unit of Measure", value: crop.unitOfMeasure)
                if crop.harvestAmount > 0 {
                    DetailRow(title: "Harvest Amount", value: "\(String(format: "%.1f", crop.harvestAmount)) \(crop.unitOfMeasure)")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct NotesCard: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct InfoPill: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// Placeholder for EditCropView
struct EditCropView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var crop: Crop
    
    var body: some View {
        NavigationView {
            Text("Edit Crop View - Coming Soon")
                .navigationTitle("Edit Crop")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    PlantingCycleView()
        .environmentObject(FarmDataManager.shared)
}