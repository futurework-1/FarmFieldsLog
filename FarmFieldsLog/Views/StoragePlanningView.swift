import SwiftUI

struct StoragePlanningView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingAddItem = false
    @State private var showingAddInventoryOverlay = false
    
    var hasStorageItems: Bool {
        !dataManager.storageItems.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
                VStack(spacing: 0) {
                // Фиксированный заголовок
                Image("warehouse_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 105)
                    .padding(.top, 20)
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 20)
                        
                        // Контент склада
                        StorageContentView(dataManager: dataManager)
                            .id("storage_content_\(dataManager.storageItems.count)")
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 30)
                        
                        // Кнопка Add inventory
                        Button(action: {
                            showingAddInventoryOverlay = true
                        }) {
                            Image("btn_add_inventory")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 340)
                        }
                        
                        // Нижний отступ для tab bar
                        Spacer()
                            .frame(height: 150)
                    }
                }
            }
        }
        .overlay(
            // Add Inventory Overlay
            Group {
                if showingAddInventoryOverlay {
                    AddInventoryOverlay(
                        isPresented: $showingAddInventoryOverlay,
                        dataManager: dataManager
                    )
                }
            }
        )
        .onChange(of: showingAddInventoryOverlay) { isShowing in
            if !isShowing {
                // Когда overlay закрывается, принудительно обновляем UI
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

// MARK: - Add Inventory Overlay
struct AddInventoryOverlay: View {
    @Binding var isPresented: Bool
    let dataManager: FarmDataManager
    @State private var selectedCategory: StorageItem.StorageCategory = .feed
    @State private var itemName: String = ""
    @State private var quantity: String = ""
    @State private var isQuantityFieldFocused: Bool = false
    @State private var hasScrolled: Bool = false
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Доступные категории как на скриншоте
    private let availableCategories: [StorageItem.StorageCategory] = [.feed, .fertilizer, .seeds, .tools]
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
        VStack(spacing: 0) {
                // Header с кнопкой назад и заголовком (фиксированный)
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
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 10)
                        
                        // Секция CATEGORY
                        VStack(spacing: 16) {
                            // Заголовок CATEGORY
                            HStack {
                                Text("CATEGORY")
                                    .font(.custom("Chango-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // Кнопки категорий
                            VStack(spacing: 8) {
                                ForEach(availableCategories, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: {
                                            selectedCategory = category
                                            // Скрываем клавиатуру при выборе категории
                                            hideKeyboard()
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Отступ между секциями
                Spacer()
                            .frame(height: 10)
                        
                        // Текстфилды
                        VStack(spacing: 16) {
                            // ITEM NAME
                            GameTextField(
                                placeholder: "ITEM NAME",
                                text: $itemName,
                                characterLimit: 20
                            )
                            
                            // QUANTITY
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
                        
                        // Отступ перед кнопкой
                Spacer()
                            .frame(height: 50)
                        
                                        // Кнопка SAVE
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
                        
                        // Нижний отступ для tab bar и клавиатуры
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
            
            // Подсказка о прокрутке
            if !hasScrolled {
                VStack {
                    Spacer()
                    
                    ZStack {
                        
                        // Анимированная подсказка
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
                        .padding(.bottom, 120) // Отступ от tab bar
                    }
                }
                .allowsHitTesting(false) // Не блокируем взаимодействие с элементами под подсказкой
            }
        }
        .onTapGesture {
            // Скрываем клавиатуру при тапе на пустое место
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения элемента склада
    private func saveItem() {
        // Очищаем единицы измерения из поля quantity
        let cleanQuantity = quantity.replacingOccurrences(of: " \(dataManager.settings.selectedPrimaryUnit.shortName)", with: "")
        
        guard let quantityValue = Double(cleanQuantity), quantityValue > 0 else {
            return
        }
        
        let newItem = StorageItem(
            name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            currentStock: quantityValue,
            minimumStock: quantityValue * 0.2, // Устанавливаем минимум как 20% от текущего количества
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
            // Когда поле теряет фокус, добавляем единицу измерения если её нет
            let unit = dataManager.settings.selectedPrimaryUnit.shortName
            if !quantity.hasSuffix(" \(unit)") {
                quantity = quantity + " \(unit)"
            }
        } else if focused {
            // Когда поле получает фокус, убираем единицу измерения для редактирования
            let unit = dataManager.settings.selectedPrimaryUnit.shortName
            if quantity.hasSuffix(" \(unit)") {
                quantity = String(quantity.dropLast(unit.count + 1))
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: StorageItem.StorageCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Фоновое изображение для категории
                Image(categoryImageName(for: category))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 340)
                    .opacity(isSelected ? 1.0 : 0.7) // Выделение выбранной категории
                
                HStack(spacing: 12) {
                    // Иконка категории
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
        .scaleEffect(isSelected ? 1.02 : 1.0) // Легкое увеличение выбранной категории
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

// MARK: - Game Text Field
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
            // Фоновое изображение для текстфилда
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
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
                        
                        // Если это поле только для цифр, оставляем только цифры
                        if isNumericOnly {
                            filteredValue = newValue.filter { $0.isNumber }
                        }
                        
                        // Ограничение символов
                        if filteredValue.count > characterLimit {
                            filteredValue = String(filteredValue.prefix(characterLimit))
                        }
                        
                        // Обновляем только если значение изменилось
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

// MARK: - Storage Content View
struct StorageContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    
    var hasStorageItems: Bool {
        !dataManager.storageItems.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if hasStorageItems {
                // Список складских элементов
                StorageItemsSection(dataManager: dataManager)
                
                // Секция EVENT
                EventSection()
                
                // Сезоны (горизонтальный скролл)
                SeasonsSection()
                
                TasksSection()
            } else {
                // Пустое состояние
                Image("theresnot_text")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 10)
            }
        }
    }
}

// MARK: - Storage Items Section
struct StorageItemsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Скроллируемый список всех элементов склада
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(dataManager.storageItems) { item in
                        StorageItemCard(item: item)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 160) // Ограничиваем высоту для скролла
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Storage Item Card
struct StorageItemCard: View {
    let item: StorageItem
    
    var body: some View {
        ZStack {
            Image("field")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
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
                
                // Индикатор категории
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

// MARK: - Event Section
struct EventSection: View {
    var body: some View {
        VStack(spacing: 8) {
            // Заголовок EVENT с кнопкой плюс
            HStack {
                Image("event_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 12)
                
                Spacer()
                
                Button(action: {
                    // TODO: Добавить событие
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
            }
            .padding(.horizontal, 32)
            
            // Пример события
            ZStack {
                Image("field")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 340)
                
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
                .padding(.horizontal, 46)
                .padding(.vertical, 15)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Seasons Section
struct SeasonsSection: View {
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
                            isSelected: index == 0 // SPRING выбрана по умолчанию
                        )
                    }
                }
                .padding(.horizontal, 26)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Season Button
struct SeasonButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            // TODO: Выбор сезона
        }) {
            ZStack {
                Image("my_tab")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110)
                HStack(spacing: 2) {
                    Text(emoji)
                        .font(.system(size: 16))
                    
                    Text(title)
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tasks Section
struct TasksSection: View {
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
                    // TODO: Добавить событие
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
            }
            .padding(.horizontal, 10)
            // Пример задач
   
                ZStack {
                    Image("field")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                    
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
                        
                        // Индикатор сезона
                        ZStack {
                            Image("my_around_tab")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                            HStack(spacing: 4) {
                                Text("🌸")
                                    .font(.system(size: 10))
                                Text("SPRING")
                                    .font(.custom("Chango-Regular", size: 8))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                }
            
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}

// MARK: - Поддерживающие компоненты (используются в AddStorageItemView)

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
            // Устанавливаем единицу измерения из настроек
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

#Preview("Storage Planning - Empty State") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
}

#Preview("Storage Planning - With Data") {
    let dataManager = FarmDataManager.shared
    
    // Добавляем тестовые данные
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
