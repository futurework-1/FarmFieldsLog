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
                    Image("warehouse_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 105)
                    Spacer()
                
                if !hasStorageItems {
                    // Пустое состояние
                    Image("theresnot_text")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 10)
            } else {
                    // Здесь будет контент когда есть данные
                    // TODO: Реализовать список складских элементов
                    Text("Storage items will be shown here")
                        .font(.custom("Chango-Regular", size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                
                Spacer()
                
                                // Кнопка Add inventory
                Button(action: {
                    showingAddInventoryOverlay = true
                }) {
                    Image("btn_add_inventory")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                }
              
                .padding(.bottom, 200) // Место для tab bar
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
                        
                        // Кнопка NEXT
                        Button(action: {
                            // TODO: Реализовать функциональность добавления
                            print("Next button tapped - будет реализовано позже")
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

#Preview("Storage Planning - Add Inventory Overlay") {
    StoragePlanningView()
        .environmentObject(FarmDataManager.shared)
        .onAppear {
            // Симулируем открытие overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Небольшая задержка для корректного отображения
            }
        }
        .overlay(
            AddInventoryOverlay(
                isPresented: .constant(true),
                dataManager: FarmDataManager.shared
            )
        )
}
