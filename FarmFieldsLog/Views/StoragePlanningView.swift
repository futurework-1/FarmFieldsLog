import SwiftUI

struct StoragePlanningView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var selectedTab = 0
    @State private var showingAddItem = false
    @State private var showingAddEvent = false
    @State private var selectedItem: StorageItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Storage").tag(0)
                    Text("Planning").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    StorageListView(
                        showingAddItem: $showingAddItem,
                        selectedItem: $selectedItem
                    )
                } else {
                    PlanningListView(showingAddEvent: $showingAddEvent)
                }
            }
            .navigationTitle("Storage & Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedTab == 0 {
                            showingAddItem = true
                        } else {
                            showingAddEvent = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddStorageItemView()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
        .sheet(item: $selectedItem) { item in
            StorageItemDetailView(item: item)
        }
    }
}

struct StorageListView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @Binding var showingAddItem: Bool
    @Binding var selectedItem: StorageItem?
    @State private var searchText = ""
    @State private var selectedCategoryFilter: StorageItem.StorageCategory?
    @State private var showLowStockOnly = false
    
    var filteredItems: [StorageItem] {
        var items = dataManager.storageItems
        
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.supplier.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let categoryFilter = selectedCategoryFilter {
            items = items.filter { $0.category == categoryFilter }
        }
        
        if showLowStockOnly {
            items = items.filter { $0.isLowStock }
        }
        
        return items.sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var lowStockCount: Int {
        dataManager.storageItems.filter { $0.isLowStock }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Low Stock Alert
            if lowStockCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(lowStockCount) item\(lowStockCount == 1 ? "" : "s") running low")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("View") {
                        showLowStockOnly.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
            }
            
            // Search and Filters
            VStack(spacing: 12) {
                SearchBar(text: $searchText)
                
                HStack {
                    Toggle("Low Stock Only", isOn: $showLowStockOnly)
                        .font(.caption)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedCategoryFilter == nil
                        ) {
                            selectedCategoryFilter = nil
                        }
                        
                        ForEach(StorageItem.StorageCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategoryFilter == category
                            ) {
                                selectedCategoryFilter = category == selectedCategoryFilter ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            // Storage Items List
            if filteredItems.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "cube.box",
                    title: "No Storage Items",
                    subtitle: searchText.isEmpty ? "Start by adding your first storage item" : "No items match your filters",
                    buttonTitle: "Add Item"
                ) {
                    showingAddItem = true
                }
                Spacer()
            } else {
                List {
                    ForEach(filteredItems) { item in
                        StorageItemRowView(item: item) {
                            selectedItem = item
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        dataManager.deleteStorageItem(at: offsets)
    }
}

struct PlanningListView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @Binding var showingAddEvent: Bool
    @State private var selectedEventTypeFilter: FarmEvent.EventType?
    
    var upcomingEvents: [FarmEvent] {
        var events = dataManager.events.filter { !$0.isCompleted }
        
        if let typeFilter = selectedEventTypeFilter {
            events = events.filter { $0.eventType == typeFilter }
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    var eventsByMonth: [(String, [FarmEvent])] {
        let grouped = Dictionary(grouping: upcomingEvents) { event in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: event.date)
        }
        
        return grouped.sorted { first, second in
            let firstDate = upcomingEvents.first { event in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: event.date) == first.0
            }?.date ?? Date.distantFuture
            
            let secondDate = upcomingEvents.first { event in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: event.date) == second.0
            }?.date ?? Date.distantFuture
            
            return firstDate < secondDate
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Event Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedEventTypeFilter == nil
                    ) {
                        selectedEventTypeFilter = nil
                    }
                    
                    ForEach(FarmEvent.EventType.allCases, id: \.self) { eventType in
                        FilterChip(
                            title: eventType.rawValue,
                            isSelected: selectedEventTypeFilter == eventType
                        ) {
                            selectedEventTypeFilter = eventType == selectedEventTypeFilter ? nil : eventType
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            // Events List
            if upcomingEvents.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "calendar",
                    title: "No Planned Events",
                    subtitle: "Schedule your farm activities",
                    buttonTitle: "Add Event"
                ) {
                    showingAddEvent = true
                }
                Spacer()
            } else {
                List {
                    ForEach(eventsByMonth, id: \.0) { month, events in
                        Section(header: Text(month)) {
                            ForEach(events) { event in
                                PlanningEventRowView(event: event)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

// Supporting Views
struct StorageItemRowView: View {
    let item: StorageItem
    let onTap: () -> Void
    
    var stockPercentage: Double {
        guard item.minimumStock > 0 else { return 1.0 }
        return min(item.currentStock / item.minimumStock, 1.0)
    }
    
    var stockColor: Color {
        if stockPercentage <= 0.2 {
            return .red
        } else if stockPercentage <= 0.5 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category Icon
                Image(systemName: item.category.icon)
                    .font(.title3)
                    .foregroundColor(item.category.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if item.isLowStock {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(String(format: "%.1f", item.currentStock)) \(item.unit)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(stockColor)
                        
                        Text("/ \(String(format: "%.1f", item.minimumStock))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Stock Level Bar
                        ProgressView(value: stockPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: stockColor))
                            .frame(width: 60)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct PlanningEventRowView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    let event: FarmEvent
    
    var daysUntil: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: event.date).day ?? 0
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days < 0 {
            return "\(-days) days ago"
        } else {
            return "In \(days) days"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                var updatedEvent = event
                updatedEvent.isCompleted = !event.isCompleted
                dataManager.updateEvent(updatedEvent)
            } label: {
                Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(event.isCompleted ? .green : .gray)
            }
            
            Image(systemName: event.eventType.icon)
                .font(.title3)
                .foregroundColor(event.eventType.color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(event.isCompleted)
                    .foregroundColor(event.isCompleted ? .secondary : .primary)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(event.eventType.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(event.eventType.color.opacity(0.2))
                    .foregroundColor(event.eventType.color)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(daysUntil)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                
                Text(event.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Placeholder Views
struct StorageItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: StorageItem
    
    var body: some View {
        NavigationView {
            Text("Storage Item Detail View - Coming Soon")
                .navigationTitle(item.name)
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

struct AddStorageItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    
    @State private var name = ""
    @State private var category = StorageItem.StorageCategory.feed
    @State private var currentStock: Double = 0
    @State private var minimumStock: Double = 0
    @State private var unit = "kg"
    @State private var expirationDate: Date?
    @State private var hasExpirationDate = false
    @State private var cost: Double = 0
    @State private var supplier = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(StorageItem.StorageCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    TextField("Unit", text: $unit)
                }
                
                Section(header: Text("Stock Levels")) {
                    HStack {
                        Text("Current Stock")
                        Spacer()
                        TextField("0", value: $currentStock, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Minimum Stock")
                        Spacer()
                        TextField("0", value: $minimumStock, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Additional Info")) {
                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("0", value: $cost, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Supplier", text: $supplier)
                    
                    Toggle("Has Expiration Date", isOn: $hasExpirationDate)
                    
                    if hasExpirationDate {
                        DatePicker(
                            "Expiration Date",
                            selection: Binding(
                                get: { expirationDate ?? Date() },
                                set: { expirationDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle("Add Storage Item")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || unit.isEmpty)
                }
            }
        }
        .onChange(of: hasExpirationDate) { newValue in
            if !newValue {
                expirationDate = nil
            }
        }
    }
    
    private func saveItem() {
        let newItem = StorageItem(
            name: name,
            category: category,
            currentStock: currentStock,
            minimumStock: minimumStock,
            unit: unit,
            expirationDate: hasExpirationDate ? expirationDate : nil,
            lastUpdated: Date(),
            cost: cost,
            supplier: supplier
        )
        
        dataManager.addStorageItem(newItem)
        dismiss()
    }
}

#Preview {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
}