import SwiftUI
struct StoragePlanningView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingAddItem = false
    @State private var showingAddInventoryOverlay = false
    @State private var showingAddEventOverlay = false
    @State private var showingAddTaskOverlay = false
    @State private var selectedSeason: String = "SPRING"
    var hasStorageItems: Bool {
        !dataManager.storageItems.isEmpty
    }
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
                VStack(spacing: 0) {
                Image("warehouse_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 105)
                    .padding(.top, 20)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        StorageContentView(
                            dataManager: dataManager,
                            selectedSeason: $selectedSeason,
                            onAddEvent: {
                                showingAddEventOverlay = true
                            },
                            onAddTask: {
                                showingAddTaskOverlay = true
                            }
                        )
                        .id("storage_content_\(dataManager.storageItems.count)")
                        Spacer()
                            .frame(height: 30)
                        Button(action: {
                            showingAddInventoryOverlay = true
                        }) {
                            Image("btn_add_inventory")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 16)
                        }
                        Spacer()
                            .frame(height: 150)
                    }
                }
            }
        }
        .overlay(
            Group {
                if showingAddInventoryOverlay {
                    AddInventoryOverlay(
                        isPresented: $showingAddInventoryOverlay,
                        dataManager: dataManager
                    )
                } else if showingAddEventOverlay {
                    AddEventOverlay(
                        isPresented: $showingAddEventOverlay,
                        dataManager: dataManager
                    )
                } else if showingAddTaskOverlay {
                    AddTaskOverlay(
                        isPresented: $showingAddTaskOverlay,
                        dataManager: dataManager
                    )
                }
            }
        )
        .onChange(of: showingAddInventoryOverlay) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingAddEventOverlay) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingAddTaskOverlay) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddStorageItemView()
        }
    }
}
struct AddInventoryOverlay: View {
    @Binding var isPresented: Bool
    let dataManager: FarmDataManager
    @State private var selectedCategory: StorageItem.StorageCategory = .feed
    @State private var itemName: String = ""
    @State private var quantity: String = ""
    @State private var isQuantityFieldFocused: Bool = false
    @State private var hasScrolled: Bool = false
    private var isFormValid: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private let availableCategories: [StorageItem.StorageCategory] = [.feed, .fertilizer, .seeds, .tools]
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
                    Image("add_invent_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                    Spacer()
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 10)
                        VStack(spacing: 16) {
                            HStack {
                                Text("CATEGORY")
                                    .font(.custom("Chango-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            VStack(spacing: 8) {
                                ForEach(availableCategories, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: {
                                            selectedCategory = category
                                            hideKeyboard()
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                Spacer()
                            .frame(height: 10)
                        VStack(spacing: 16) {
                            GameTextField(
                                placeholder: "ITEM NAME",
                                text: $itemName,
                                characterLimit: 20
                            )
                            GameTextField(
                                placeholder: "QUANTITY",
                                text: $quantity,
                                characterLimit: 3,
                                keyboardType: .numberPad,
                                isQuantityField: true,
                                unit: dataManager.settings.selectedPrimaryUnit.shortName,
                                isFocused: $isQuantityFieldFocused,
                                onFocusChange: { focused in
                                    handleQuantityFocusChange(focused)
                                },
                                isNumericOnly: true
                            )
                        }
                        .padding(.horizontal, 20)
                Spacer()
                            .frame(height: 50)
                Button(action: {
                    saveItem()
                }) {
                            Image("btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 350)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !hasScrolled {
                                hasScrolled = true
                            }
                        }
                )
            }
            if !hasScrolled {
                VStack {
                    Spacer()
                    ZStack {
                        VStack(spacing: 8) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .scaleEffect(1.2)
                                .animation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true),
                                    value: hasScrolled
                                )
                            Text("Scroll for Next")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.white)
                                .opacity(0.7)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                        .padding(.bottom, 120)
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveItem() {
        let cleanQuantity = quantity.replacingOccurrences(of: " \(dataManager.settings.selectedPrimaryUnit.shortName)", with: "")
        guard let quantityValue = Double(cleanQuantity), quantityValue > 0 else {
            return
        }
        let newItem = StorageItem(
            name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            currentStock: quantityValue,
            minimumStock: quantityValue * 0.2,
            unit: dataManager.settings.selectedPrimaryUnit.shortName,
            expirationDate: nil,
            lastUpdated: Date(),
            cost: 0,
            supplier: ""
        )
        dataManager.addStorageItem(newItem)
        isPresented = false
    }
    private func handleQuantityFocusChange(_ focused: Bool) {
        if !focused && !quantity.isEmpty {
            let unit = dataManager.settings.selectedPrimaryUnit.shortName
            if !quantity.hasSuffix(" \(unit)") {
                quantity = quantity + " \(unit)"
            }
        } else if focused {
            let unit = dataManager.settings.selectedPrimaryUnit.shortName
            if quantity.hasSuffix(" \(unit)") {
                quantity = String(quantity.dropLast(unit.count + 1))
            }
        }
    }
}
struct CategoryButton: View {
    let category: StorageItem.StorageCategory
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(categoryImageName(for: category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 340)
                    .opacity(isSelected ? 1.0 : 0.7)
                HStack(spacing: 12) {
                    Text(categoryEmoji(for: category))
                        .font(.system(size: 24))
                        .hidden()
                    Text(category.rawValue.uppercased())
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        .hidden()
                Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    private func categoryImageName(for category: StorageItem.StorageCategory) -> String {
        switch category {
        case .feed: return "field_feed"
        case .fertilizer: return "field_fertilizer"
        case .seeds: return "field_seed"
        case .tools: return "field_tools"
        default: return "field_empty"
        }
    }
    private func categoryEmoji(for category: StorageItem.StorageCategory) -> String {
        switch category {
        case .feed: return "🌾"
        case .fertilizer: return "🌿"
        case .seeds: return "🌱"
        case .tools: return "🔧"
        default: return "📦"
        }
    }
}
struct GameTextField: View {
    let placeholder: String
    @Binding var text: String
    let characterLimit: Int
    var keyboardType: UIKeyboardType = .default
    var isQuantityField: Bool = false
    var unit: String = ""
    var isFocused: Binding<Bool>?
    var onFocusChange: ((Bool) -> Void)?
    var isNumericOnly: Bool = false
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                    HStack {
                TextField("", text: $text, onEditingChanged: { editing in
                    isFocused?.wrappedValue = editing
                    onFocusChange?(editing)
                })
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.gray)
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .onChange(of: text) { newValue in
                        var filteredValue = newValue
                        if isNumericOnly {
                            filteredValue = newValue.filter { $0.isNumber }
                        }
                        if filteredValue.count > characterLimit {
                            filteredValue = String(filteredValue.prefix(characterLimit))
                        }
                        if filteredValue != newValue {
                            text = filteredValue
                        }
                    }
                        Spacer()
                if isQuantityField && !unit.isEmpty && !(isFocused?.wrappedValue ?? false) {
                    Text(unit)
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        }
    }
}
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
struct StorageContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedSeason: String
    let onAddEvent: () -> Void
    let onAddTask: () -> Void
    var hasStorageItems: Bool {
        !dataManager.storageItems.isEmpty
    }
    var body: some View {
        VStack(spacing: 0) {
            if hasStorageItems {
                StorageItemsSection(dataManager: dataManager)
                EventSection(
                    onAddEvent: onAddEvent,
                    dataManager: dataManager
                )
                SeasonsSection(selectedSeason: $selectedSeason)
                TasksSection(
                    dataManager: dataManager,
                    selectedSeason: selectedSeason,
                    onAddTask: onAddTask
                )
            } else {
                Image("theresnot_text")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 10)
            }
        }
    }
}
struct StorageItemsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(dataManager.storageItems) { item in
                        StorageItemCard(item: item)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 150)
        }
        .padding(.horizontal, 12)
    }
}
struct StorageItemCard: View {
    let item: StorageItem
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name.uppercased())
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Text("\(String(format: "%.0f", item.currentStock)) \(item.unit)")
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                Spacer()
                Image(categoryIconName(for: item.category))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 15)
        }
    }
    private func categoryIconName(for category: StorageItem.StorageCategory) -> String {
        switch category {
        case .feed: return "0icon"
        case .fertilizer: return "1icon"
        case .seeds: return "2icon"
        case .tools: return "3icon"
        default: return "0icon"
        }
    }
}
struct EventSection: View {
    let onAddEvent: () -> Void
    @ObservedObject var dataManager: FarmDataManager
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image("event_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 12)
                Spacer()
                Button(action: {
                    onAddEvent()
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
            }
            .padding(.horizontal, 32)
            if dataManager.events.isEmpty {
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 16)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TAP PLUS")
                                .font(.custom("Chango-Regular", size: 11))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Text("ADD YOU FIRST REMINDER!")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 15)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(dataManager.events) { event in
                            StorageEventCard(event: event)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 160)
            }
        }
        .padding(.top, 20)
    }
}
struct StorageEventCard: View {
    let event: FarmEvent
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: event.date)
    }
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title.uppercased())
                        .font(.custom("Chango-Regular", size: 11))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Text(formattedDate)
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                Spacer()
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 15)
        }
    }
}
struct SeasonsSection: View {
    @Binding var selectedSeason: String
    let seasons = ["SPRING", "SUMMER", "AUTUMN", "WINTER"]
    let seasonEmojis = ["🌸", "☀️", "🍂", "❄️"]
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(seasons.enumerated()), id: \.offset) { index, season in
                        SeasonButton(
                            title: season,
                            emoji: seasonEmojis[index],
                            isSelected: selectedSeason == season,
                            action: {
                                selectedSeason = season
                            }
                        )
                    }
                }
                .padding(.horizontal, 26)
            }
        }
        .padding(.top, 20)
    }
}
struct SeasonButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(isSelected ? "my_around_tab" : "my_tab")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110)
                    .opacity(isSelected ? 1.0 : 0.7)
                HStack(spacing: 2) {
                    Text(emoji)
                        .font(.system(size: 16))
                    Text(title)
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(isSelected ? .yellow : .white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
struct TasksSection: View {
    @ObservedObject var dataManager: FarmDataManager
    let selectedSeason: String
    let onAddTask: () -> Void
    private var filteredTasks: [FarmTask] {
        return dataManager.tasks.filter { task in
            task.description.contains(selectedSeason)
        }
    }
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image("event_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 12)
                    .hidden()
                Spacer()
                Button(action: {
                    onAddTask()
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
            }
            .padding(.horizontal, 10)
            if filteredTasks.isEmpty {
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TAP PLUS")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Text("AND ADD YOUR FIRST EVENT")
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        }
                        Spacer()
                        ZStack {
                            Image("my_around_tab")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75)
                            HStack(spacing: 4) {
                                Text(seasonEmoji(for: selectedSeason))
                                    .font(.system(size: 10))
                                Text(selectedSeason)
                                    .font(.custom("Chango-Regular", size: 8))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTasks) { task in
                            TaskCard(task: task, selectedSeason: selectedSeason)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(.top, 25)
        .padding(.horizontal, 20)
    }
    private func seasonEmoji(for season: String) -> String {
        switch season {
        case "SPRING": return "🌸"
        case "SUMMER": return "☀️"
        case "AUTUMN": return "🍂"
        case "WINTER": return "❄️"
        default: return "🌸"
        }
    }
}
struct TaskCard: View {
    let task: FarmTask
    let selectedSeason: String
    private var seasonEmoji: String {
        switch selectedSeason {
        case "SPRING": return "🌸"
        case "SUMMER": return "☀️"
        case "AUTUMN": return "🍂"
        case "WINTER": return "❄️"
        default: return "🌸"
        }
    }
    private var monthFromDescription: String {
        let parts = task.description.components(separatedBy: " in ")
        if parts.count > 1 {
            return parts[1]
        }
        return ""
    }
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title.uppercased())
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    if !monthFromDescription.isEmpty {
                        Text(monthFromDescription.uppercased())
                            .font(.custom("Chango-Regular", size: 10))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                }
                Spacer()
                ZStack {
                    Image("my_around_tab")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75)
                    HStack(spacing: 4) {
                        Text(seasonEmoji)
                            .font(.system(size: 10))
                        Text(selectedSeason)
                            .font(.custom("Chango-Regular", size: 8))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
}
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
    @State private var unit = ""
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
        .onAppear {
            unit = dataManager.settings.selectedPrimaryUnit.shortName
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
struct AddEventOverlay: View {
    @Binding var isPresented: Bool
    let dataManager: FarmDataManager
    @State private var eventTitle: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasScrolled: Bool = false
    private var isFormValid: Bool {
        !eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
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
                    Image("add_text")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        HStack {
                            Text("EVENT")
                                .font(.custom("Chango-Regular", size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        VStack(spacing: 16) {
                            GameTextField(
                                placeholder: "TITLE",
                                text: $eventTitle,
                                characterLimit: 20
                            )
                            EventDateField(
                                selectedDate: $selectedDate
                            )
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 60)
                        Button(action: {
                            saveEvent()
                        }) {
                            Image("btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 350)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !hasScrolled {
                                hasScrolled = true
                            }
                        }
                )
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveEvent() {
        let newEvent = FarmEvent(
            title: eventTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: "Reminder",
            date: selectedDate,
            eventType: .other,
            isCompleted: false,
            reminderDate: selectedDate
        )
        dataManager.addEvent(newEvent)
        isPresented = false
    }
}
struct EventDateField: View {
    @Binding var selectedDate: Date
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: selectedDate)
    }
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .tint(.white)
                    .colorScheme(.dark)
                Spacer()
                Text(formattedDate)
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        }
    }
}
struct AddTaskOverlay: View {
    @Binding var isPresented: Bool
    let dataManager: FarmDataManager
    @State private var taskTitle: String = ""
    @State private var selectedSeason: String = "SPRING"
    @State private var selectedMonth: String = ""
    @State private var isMonthDropdownOpen: Bool = false
    @State private var hasScrolled: Bool = false
    private let seasons = [
        ("SPRING", "🌸"),
        ("SUMMER", "☀️"),
        ("AUTUMN", "🍂"),
        ("WINTER", "❄️")
    ]
    private let months = [
        "JANUARY", "FEBRUARY", "MARCH", "APRIL",
        "MAY", "JUNE", "JULY", "AUGUST",
        "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
    ]
    private var isFormValid: Bool {
        !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedMonth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
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
                    Image("add_task_my")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                    Spacer()
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        HStack {
                            Text("EVENT")
                                .font(.custom("Chango-Regular", size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        GameTextField(
                            placeholder: "TITLE",
                            text: $taskTitle,
                            characterLimit: 15
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        VStack(spacing: 16) {
                            HStack {
                                Text("SEASON")
                                    .font(.custom("Chango-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(seasons, id: \.0) { season in
                                    SeasonSelectionButton(
                                        title: season.0,
                                        emoji: season.1,
                                        isSelected: selectedSeason == season.0,
                                        action: {
                                            selectedSeason = season.0
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 16)
                        VStack(spacing: 0) {
                            MonthDropdownField(
                                selectedMonth: $selectedMonth,
                                isOpen: $isMonthDropdownOpen,
                                months: months
                            )
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 60)
                        Button(action: {
                            saveTask()
                        }) {
                            Image("btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 350)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !hasScrolled {
                                hasScrolled = true
                            }
                        }
                )
            }
        }
        .onTapGesture {
            hideKeyboard()
            if isMonthDropdownOpen {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMonthDropdownOpen = false
                }
            }
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveTask() {
        let newTask = FarmTask(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: "Task for \(selectedSeason) in \(selectedMonth)",
            dueDate: Date(),
            priority: .medium,
            category: .other,
            createdDate: Date()
        )
        dataManager.addTask(newTask)
        isPresented = false
    }
}
struct SeasonSelectionButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 16))
                Text(title)
                    .font(.custom("Chango-Regular", size: 12))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(isSelected ? Color.yellow.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
struct MonthDropdownField: View {
    @Binding var selectedMonth: String
    @Binding var isOpen: Bool
    let months: [String]
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isOpen.toggle()
                }
            }) {
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                    HStack {
                        Text(selectedMonth.isEmpty ? "MONTH" : selectedMonth)
                            .font(.custom("Chango-Regular", size: 16))
                            .foregroundColor(selectedMonth.isEmpty ? .gray : .white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isOpen ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isOpen)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                }
            }
            .buttonStyle(PlainButtonStyle())
            if isOpen {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 0) {
                            ForEach(months, id: \.self) { month in
                                Button(action: {
                                    selectedMonth = month
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isOpen = false
                                    }
                                }) {
                                    HStack {
                                        Text(month)
                                            .font(.custom("Chango-Regular", size: 14))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedMonth == month ? 
                                        Color.yellow.opacity(0.2) : 
                                        Color.clear
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                if month != months.last {
                                    Divider()
                                        .background(Color.white.opacity(0.3))
                                        .padding(.horizontal, 25)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 25)
                    .padding(.top, -10)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
#Preview("Storage Planning - Empty State") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
}
#Preview("Storage Planning - With Data") {
    let dataManager = FarmDataManager.shared
    let testItem1 = StorageItem(
        name: "Chicken Feed",
        category: .feed,
        currentStock: 20,
        minimumStock: 5,
        unit: "kg",
        expirationDate: nil,
        lastUpdated: Date(),
        cost: 0,
        supplier: ""
    )
    let testItem3 = StorageItem(
        name: "Chicken Feed",
        category: .feed,
        currentStock: 20,
        minimumStock: 5,
        unit: "kg",
        expirationDate: nil,
        lastUpdated: Date(),
        cost: 0,
        supplier: ""
    )
    let testItem2 = StorageItem(
        name: "Corn Seeds",
        category: .seeds,
        currentStock: 15,
        minimumStock: 3,
        unit: "kg",
        expirationDate: nil,
        lastUpdated: Date(),
        cost: 0,
        supplier: ""
    )
    return StoragePlanningView()
        .environmentObject(dataManager)
        .onAppear {
            if dataManager.storageItems.isEmpty {
                dataManager.addStorageItem(testItem1)
                dataManager.addStorageItem(testItem2)
                dataManager.addStorageItem(testItem3)
            }
        }
}
#Preview("Storage Planning - Add Inventory Overlay") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
        .overlay(
            AddInventoryOverlay(
                isPresented: .constant(true),
                dataManager: FarmDataManager.shared
            )
        )
}
#Preview("Storage Planning - Add Event Overlay") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
        .overlay(
            AddEventOverlay(
                isPresented: .constant(true),
                dataManager: FarmDataManager.shared
            )
        )
}
#Preview("Storage Planning - Add Task Overlay") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
        .overlay(
            AddTaskOverlay(
                isPresented: .constant(true),
                dataManager: FarmDataManager.shared
            )
        )
}
