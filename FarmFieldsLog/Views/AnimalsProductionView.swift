import SwiftUI

struct AnimalsProductionView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var selectedTab = 0
    @State private var showingAddAnimal = false
    @State private var showingAddProduction = false
    @State private var selectedAnimal: Animal?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Animals").tag(0)
                    Text("Production").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    AnimalsListView(
                        showingAddAnimal: $showingAddAnimal,
                        selectedAnimal: $selectedAnimal
                    )
                } else {
                    ProductionListView(showingAddProduction: $showingAddProduction)
                }
            }
            .navigationTitle("Animals & Production")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedTab == 0 {
                            showingAddAnimal = true
                        } else {
                            showingAddProduction = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAnimal) {
            AddAnimalView()
        }
        .sheet(isPresented: $showingAddProduction) {
            AddProductionRecordView()
        }
        .sheet(item: $selectedAnimal) { animal in
            AnimalDetailView(animal: animal)
        }
    }
}

struct AnimalsListView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @Binding var showingAddAnimal: Bool
    @Binding var selectedAnimal: Animal?
    @State private var searchText = ""
    @State private var selectedSpeciesFilter: Animal.AnimalSpecies?
    
    var filteredAnimals: [Animal] {
        var animals = dataManager.animals
        
        if !searchText.isEmpty {
            animals = animals.filter {
                $0.breed.localizedCaseInsensitiveContains(searchText) ||
                $0.species.rawValue.localizedCaseInsensitiveContains(searchText) ||
                ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let speciesFilter = selectedSpeciesFilter {
            animals = animals.filter { $0.species == speciesFilter }
        }
        
        return animals.sorted { $0.species.rawValue < $1.species.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter
            VStack(spacing: 12) {
                SearchBar(text: $searchText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedSpeciesFilter == nil
                        ) {
                            selectedSpeciesFilter = nil
                        }
                        
                        ForEach(Animal.AnimalSpecies.allCases, id: \.self) { species in
                            FilterChip(
                                title: species.rawValue,
                                isSelected: selectedSpeciesFilter == species
                            ) {
                                selectedSpeciesFilter = species == selectedSpeciesFilter ? nil : species
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            // Animals List
            if filteredAnimals.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "pawprint",
                    title: "No Animals Yet",
                    subtitle: searchText.isEmpty ? "Start by adding your first animal" : "No animals match your search",
                    buttonTitle: "Add Animal"
                ) {
                    showingAddAnimal = true
                }
                Spacer()
            } else {
                List {
                    ForEach(filteredAnimals) { animal in
                        AnimalRowView(animal: animal) {
                            selectedAnimal = animal
                        }
                    }
                    .onDelete(perform: deleteAnimals)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private func deleteAnimals(at offsets: IndexSet) {
        dataManager.deleteAnimal(at: offsets)
    }
}

struct ProductionListView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @Binding var showingAddProduction: Bool
    @State private var selectedProductFilter: ProductionRecord.ProductType?
    
    var filteredRecords: [ProductionRecord] {
        var records = dataManager.productionRecords
        
        if let productFilter = selectedProductFilter {
            records = records.filter { $0.productType == productFilter }
        }
        
        return records.sorted { $0.date > $1.date }
    }
    
    var weeklyStats: [(ProductionRecord.ProductType, Double)] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyRecords = dataManager.productionRecords.filter { $0.date >= weekAgo }
        
        let grouped = Dictionary(grouping: weeklyRecords) { $0.productType }
        return grouped.map { (type, records) in
            let total = records.reduce(0) { $0 + $1.amount }
            return (type, total)
        }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekly Stats
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(weeklyStats, id: \.0) { stat in
                        ProductionStatCard(
                            productType: stat.0,
                            amount: stat.1
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            // Product Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedProductFilter == nil
                    ) {
                        selectedProductFilter = nil
                    }
                    
                    ForEach(ProductionRecord.ProductType.allCases, id: \.self) { product in
                        FilterChip(
                            title: product.rawValue,
                            isSelected: selectedProductFilter == product
                        ) {
                            selectedProductFilter = product == selectedProductFilter ? nil : product
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .background(Color(.systemGroupedBackground))
            
            // Production Records
            if filteredRecords.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "chart.bar",
                    title: "No Production Records",
                    subtitle: "Start tracking your farm production",
                    buttonTitle: "Add Record"
                ) {
                    showingAddProduction = true
                }
                Spacer()
            } else {
                List {
                    ForEach(filteredRecords) { record in
                        ProductionRecordRowView(record: record)
                    }
                    .onDelete(perform: deleteRecords)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private func deleteRecords(at offsets: IndexSet) {
        dataManager.deleteProductionRecord(at: offsets)
    }
}

// Supporting Views
struct AnimalRowView: View {
    let animal: Animal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Animal Icon
                Text(animal.species.icon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(animal.healthStatus.color.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(animal.species.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if animal.isHighProducer {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        Text("Count: \(animal.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Text(animal.breed)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(animal.healthStatus.color)
                            .frame(width: 8, height: 8)
                        
                        Text(animal.healthStatus.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !animal.age.isEmpty {
                            Text("Age: \(animal.age)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct ProductionStatCard: View {
    let productType: ProductionRecord.ProductType
    let amount: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: productType.icon)
                .font(.title2)
                .foregroundColor(productType.color)
            
            Text(String(format: "%.1f", amount))
                .font(.custom("Chango-Regular", size: 18))
                .foregroundColor(.primary)
            
            Text(productType.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("This Week")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 100, height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct ProductionRecordRowView: View {
    let record: ProductionRecord
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.productType.icon)
                .font(.title3)
                .foregroundColor(record.productType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.productType.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.1f", record.amount)) \(record.unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(record.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(record.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Placeholder Views
struct AnimalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let animal: Animal
    
    var body: some View {
        NavigationView {
            Text("Animal Detail View - Coming Soon")
                .navigationTitle(animal.species.rawValue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct AddProductionRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    
    @State private var productType = ProductionRecord.ProductType.eggs
    @State private var amount: Double = 0
    @State private var unit = ""
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Production Details")) {
                    Picker("Product Type", selection: $productType) {
                        ForEach(ProductionRecord.ProductType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Unit", text: $unit)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Notes")) {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Production")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(amount <= 0 || unit.isEmpty)
                }
            }
        }
        .onAppear {
            // Устанавливаем единицу измерения из настроек
            unit = dataManager.settings.selectedPrimaryUnit.shortName
        }
    }
    
    private func saveRecord() {
        let newRecord = ProductionRecord(
            date: date,
            productType: productType,
            amount: amount,
            unit: unit,
            animalId: nil,
            notes: notes
        )
        
        dataManager.addProductionRecord(newRecord)
        dismiss()
    }
}

#Preview {
    AnimalsProductionView()
        .environmentObject(FarmDataManager.shared)
}