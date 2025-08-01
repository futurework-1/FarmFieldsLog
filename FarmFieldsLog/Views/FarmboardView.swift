import SwiftUI
import UserNotifications

struct FarmboardView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingItemTypeSelection = false
    @State private var showingItemDetails = false
    @State private var selectedItemType: FarmboardItem.FarmboardItemType?
    @State private var selectedItem: FarmboardItem?
    @State private var showingItemDetailView = false
    
    // Данные формы для передачи между экранами
    @State private var cropQuantity: String = ""
    @State private var taskName: String = ""
    @State private var eventName: String = ""
    @State private var animalQuantity: String = ""
    
    var hasFarmboardItems: Bool {
        !dataManager.farmboardItems.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Фиксированный заголовок
                HStack {
                    Spacer()
                    Image("farm_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Spacer()
                }
                .padding(.top, 20)
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 20)
                        
                        // Контент farmboard
                        FarmboardContentView(
                            dataManager: dataManager,
                            selectedItem: $selectedItem
                        )
                        .id("farmboard_content_\(dataManager.farmboardItems.count)")
                        
                        // Отступ перед кнопками
                        Spacer()
                            .frame(height: 150)
                        
                        // Кнопки действий в сетке 2x2
                        HStack {
                            Button(action: {
                                selectedItemType = .crop
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_crop")
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            // Кнопка Add Animal
                            Button(action: {
                                selectedItemType = .animal
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_animal")
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            // Кнопка Add Task
                            Button(action: {
                                selectedItemType = .task
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_task")
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            // Кнопка Add Event
                            Button(action: {
                                selectedItemType = .event
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_event")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Нижний отступ для tab bar
                        Spacer()
                            .frame(height: 150)
                    }
                }
            }
        }
        .overlay(
            // Overlays
            ZStack {
                if showingItemTypeSelection {
                    FarmboardItemTypeOverlay(
                        isPresented: $showingItemTypeSelection,
                        selectedItemType: selectedItemType ?? .crop,
                        cropQuantity: $cropQuantity,
                        taskName: $taskName,
                        eventName: $eventName,
                        animalQuantity: $animalQuantity,
                        dataManager: dataManager,
                        onItemTypeConfirmed: {
                            showingItemTypeSelection = false
                            showingItemDetails = true
                        },
                        onCropSaved: {
                            showingItemTypeSelection = false
                            showingItemDetails = false
                        },
                        onAnimalSaved: {
                            showingItemTypeSelection = false
                            showingItemDetails = false
                        },
                        onTaskSaved: {
                            showingItemTypeSelection = false
                            showingItemDetails = false
                        },
                        onEventSaved: {
                            showingItemTypeSelection = false
                            showingItemDetails = false
                        }
                    )
                } else if showingItemDetails {
                    FarmboardItemDetailsOverlay(
                        isPresented: $showingItemDetails,
                        itemType: selectedItemType ?? .crop,
                        cropQuantity: cropQuantity,
                        taskName: taskName,
                        eventName: eventName,
                        animalQuantity: animalQuantity,
                        dataManager: dataManager
                    )
                } else if showingItemDetailView, let item = selectedItem {
                    FarmboardItemDetailOverlay(
                        isPresented: $showingItemDetailView,
                        item: item,
                        dataManager: dataManager,
                        onItemDeleted: {
                            selectedItem = nil
                            showingItemDetailView = false
                        }
                    )
                }
            }
        )
        .onChange(of: showingItemTypeSelection) { isShowing in
            if !isShowing {
                // Сбрасываем данные формы при закрытии
                cropQuantity = ""
                taskName = ""
                eventName = ""
                animalQuantity = ""
            }
        }
        .onChange(of: showingItemDetails) { isShowing in
            if !isShowing {
                // Сбрасываем данные формы при закрытии
                cropQuantity = ""
                taskName = ""
                eventName = ""
                animalQuantity = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingItemDetailView) { isShowing in
            if !isShowing {
                selectedItem = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: selectedItem) { item in
            if item != nil {
                showingItemDetailView = true
            }
        }
    }
}

// MARK: - Farmboard Content View
struct FarmboardContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedItem: FarmboardItem?
    
    var hasFarmboardItems: Bool {
        !dataManager.farmboardItems.isEmpty
    }
    
    // Вычисляем суммарные значения по типам
    var cropItems: [FarmboardItem] {
        dataManager.farmboardItems.filter { $0.itemType == .crop }
    }
    
    var animalItems: [FarmboardItem] {
        dataManager.farmboardItems.filter { $0.itemType == .animal }
    }
    
    var taskItems: [FarmboardItem] {
        dataManager.farmboardItems.filter { $0.itemType == .task }
    }
    
    var eventItems: [FarmboardItem] {
        dataManager.farmboardItems.filter { $0.itemType == .event }
    }
    
    var totalCropKg: Int {
        cropItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalMilkL: Int {
        animalItems.filter { $0.name == "Milk" }.reduce(0) { $0 + $1.quantity }
    }
    
    var totalEggPcs: Int {
        animalItems.filter { $0.name == "Egg" }.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if hasFarmboardItems {
                // WEEKLY CROP блок с суммарной статистикой
                WeeklyCropSummaryView(
                    totalCropKg: totalCropKg,
                    totalMilkL: totalMilkL,
                    totalEggPcs: totalEggPcs
                )
                
                // TASKS секция
                if !taskItems.isEmpty {
                    TasksSectionView(
                        tasks: taskItems,
                        selectedItem: $selectedItem
                    )
                }
                
                // EVENT секция
                if !eventItems.isEmpty {
                    EventsSectionView(
                        events: eventItems,
                        selectedItem: $selectedItem,
                        dataManager: dataManager
                    )
                }
            } else {
                // Пустое состояние
                VStack(spacing: 20) {
                    Image("theresnot_text")
                        .resizable()
                        .scaledToFit()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
        }
    }
}

// MARK: - Farmboard Items Section
struct FarmboardItemsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedItem: FarmboardItem?
    
    var body: some View {
        VStack(spacing: 8) {
            // Скроллируемый список всех элементов farmboard
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(dataManager.farmboardItems) { item in
                        FarmboardItemCard(item: item) {
                            selectedItem = item
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 300) // Ограничиваем высоту для скролла
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Farmboard Item Card
struct FarmboardItemCard: View {
    let item: FarmboardItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .frame(width: 340, height: 70)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.itemType.rawValue.uppercased())
                            .font(.custom("Chango-Regular", size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        
                        Text("\(item.quantity) \(item.unit)")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Иконка типа элемента
                    Image(item.itemType.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 20)
                }
            }
        }
    }
}

// MARK: - Weekly Crop Summary
struct WeeklyCropSummaryView: View {
    let totalCropKg: Int
    let totalMilkL: Int
    let totalEggPcs: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Заголовок WEEKLY CROP
            
            // Фон для блока
            ZStack {
                Image("week_rect")
                    .resizable()
                    .scaledToFit()
                VStack(spacing: 0) {
                    Text("WEEKLY CROP")
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                HStack(spacing: 0) {
                    // Plants (kg)
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(totalCropKg)")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            Image("crop")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        }
                        
                        Text("plants (kg)")
                            .font(.custom("Chango-Regular", size: 12))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                    
                    Spacer()
                    
                    // Разделитель
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 80)
                    
                    Spacer()
                    
                    // Milk (l)
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(totalMilkL)")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            Image("milk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        }
                        
                        Text("milk (l)")
                            .font(.custom("Chango-Regular", size: 12))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                    
                    Spacer()
                    
                    // Разделитель
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 80)
                    
                    Spacer()
                    
                    // Egg (pcs)
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(totalEggPcs)")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            Image("egg")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                        }
                        
                        Text("egg (pcs)")
                            .font(.custom("Chango-Regular", size: 12))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                }
                .padding(.horizontal, 30)
            }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Tasks Section
struct TasksSectionView: View {
    let tasks: [FarmboardItem]
    @Binding var selectedItem: FarmboardItem?
    
    // Сортируем по дате создания (свежие сверху)
    var sortedTasks: [FarmboardItem] {
        tasks.sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок TASKS
            HStack {
                Image("tasks_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Список задач (максимум 2 видимых + скролл)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(sortedTasks) { task in
                        TaskItemView(task: task) {
                            selectedItem = task
                        }
                    }
                }
            }
            .frame(maxHeight: 140) // Высота для ~2 элементов (60*2 + отступы)
        }
    }
}

// MARK: - Task Item
struct TaskItemView: View {
    let task: FarmboardItem
    let onTap: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .frame(width: 340, height: 60)
                
                HStack {
                    // Checkbox
                    Button(action: {
                        isCompleted.toggle()
                    }) {
                        ZStack {
                            Rectangle()
                                .stroke(Color.yellow, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Image("my_task")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                    
                    // Название задачи
                    Text(task.name.uppercased())
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Events Section
struct EventsSectionView: View {
    let events: [FarmboardItem]
    @Binding var selectedItem: FarmboardItem?
    let dataManager: FarmDataManager
    
    // Сортируем по дате напоминания (ближайшие сверху) или по дате создания
    var sortedEvents: [FarmboardItem] {
        events.sorted { event1, event2 in
            if let date1 = event1.scheduledDate, let date2 = event2.scheduledDate {
                return date1 < date2 // Ближайшие события сверху
            } else if event1.scheduledDate != nil {
                return true // События с датой выше тех, что без даты
            } else if event2.scheduledDate != nil {
                return false
            } else {
                return event1.createdDate > event2.createdDate // По дате создания
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок EVENT
            HStack {
                Image("event_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Список событий (максимум 2 видимых + скролл)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(sortedEvents) { event in
                        EventItemView(event: event, dataManager: dataManager) {
                            selectedItem = event
                        }
                    }
                }
            }
            .frame(maxHeight: 140) // Высота для ~2 элементов (60*2 + отступы)
        }
    }
}

// MARK: - Event Item
struct EventItemView: View {
    let event: FarmboardItem
    let dataManager: FarmDataManager
    let onTap: () -> Void
    
    // Вычисляем время до события
    private var timeUntilEvent: String {
        guard let scheduledDate = event.scheduledDate else {
            return "NO DATE"
        }
        
        let timeInterval = scheduledDate.timeIntervalSince(Date())
        
        if timeInterval <= 0 {
            // Событие прошло - удаляем его
            DispatchQueue.main.async {
                dataManager.deleteFarmboardItem(event)
            }
            return "EXPIRED"
        }
        
        let days = Int(timeInterval / 86400)
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if days > 0 {
            return days == 1 ? "TOMORROW" : "IN \(days) DAYS"
        } else if hours > 0 {
            return hours == 1 ? "IN 1 HOUR" : "IN \(hours) HOURS"
        } else if minutes > 0 {
            return minutes == 1 ? "IN 1 MIN" : "IN \(minutes) MINS"
        } else {
            return "NOW"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .frame(width: 340, height: 60)
                
                HStack {
                    // Иконка события
                    Image("my_event")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Время до события
                        Text(timeUntilEvent)
                            .font(.custom("Chango-Regular", size: 10))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        
                        // Название события
                        Text(event.name.uppercased())
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            // Проверяем при появлении, не истекло ли время
            if let scheduledDate = event.scheduledDate, scheduledDate <= Date() {
                dataManager.deleteFarmboardItem(event)
            }
        }
    }
}

// MARK: - Overlay Components

// Главный overlay для выбора подтипа элемента
struct FarmboardItemTypeOverlay: View {
    @Binding var isPresented: Bool
    let selectedItemType: FarmboardItem.FarmboardItemType
    @Binding var cropQuantity: String
    @Binding var taskName: String
    @Binding var eventName: String
    @Binding var animalQuantity: String
    let dataManager: FarmDataManager
    let onItemTypeConfirmed: () -> Void
    let onCropSaved: () -> Void
    let onAnimalSaved: () -> Void
    let onTaskSaved: () -> Void
    let onEventSaved: () -> Void
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header с кнопкой назад и заголовком
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
                    
                    Image(getHeaderImageName())
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
                
                Spacer()
                
                // Основной контент в зависимости от типа
                switch selectedItemType {
                case .crop:
                    CropTypeSelectionView(
                        cropQuantity: $cropQuantity, 
                        dataManager: dataManager, 
                        onCropSaved: onCropSaved
                    )
                case .animal:
                    AnimalTypeSelectionView(
                        animalQuantity: $animalQuantity, 
                        dataManager: dataManager, 
                        onAnimalSaved: onAnimalSaved
                    )
                case .task:
                    TaskTypeSelectionView(
                        taskName: $taskName, 
                        dataManager: dataManager, 
                        onTaskSaved: onTaskSaved
                    )
                case .event:
                    EventTypeSelectionView(
                        eventName: $eventName, 
                        dataManager: dataManager, 
                        onEventSaved: onEventSaved
                    )
                }
                
                Spacer()
            }
        }
    }
    
    private func getHeaderImageName() -> String {
        switch selectedItemType {
        case .crop: return "add_crop_text"
        case .animal: return "add_animal_text"
        case .task: return "add_task_text"
        case .event: return "add_event_text"
        }
    }
}

// MARK: - Type Selection Components

// Выбор типа культуры
struct CropTypeSelectionView: View {
    @Binding var cropQuantity: String
    let dataManager: FarmDataManager
    let onCropSaved: () -> Void
    
    @State private var unit: String = "kg"
    
    // Проверка готовности формы - максимум 3 цифры и не пустое
    private var isFormValid: Bool {
        !cropQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        cropQuantity.count <= 3 && 
        cropQuantity.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Верхний отступ
                Spacer()
                    .frame(height: 20)
                
                // Иконка культуры (уменьшенная)
                Image("crop")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                
                // Отступ перед полем ввода
                Spacer()
                    .frame(height: 40)
                
                // Текстовое поле для количества с единицами измерения
                ZStack {
                    AnimalTextField(
                        placeholder: "QUANTITY",
                        text: $cropQuantity,
                        keyboardType: .numberPad,
                        isNumericOnly: true
                    )
                    
                    // Отображение единиц измерения справа
                    HStack {
                        Spacer()
                        Text(unit)
                            .font(.custom("Chango-Regular", size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            .padding(.trailing, 20)
                    }
                }
                .onChange(of: cropQuantity) { newValue in
                    // Ограничиваем до 3 цифр и только числа
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > 3 {
                        cropQuantity = String(filtered.prefix(3))
                    } else {
                        cropQuantity = filtered
                    }
                }
                
                // Отступ перед кнопкой
                Spacer()
                    .frame(height: 30)
                
                // Кнопка сохранения
                Button(action: {
                    if isFormValid {
                        saveCrop()
                    }
                }) {
                    Image("btn_save")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                        .opacity(isFormValid ? 1 : 0.5)
                }
                .disabled(!isFormValid)
                .buttonStyle(PlainButtonStyle())
                
                // Нижний отступ для клавиатуры
                Spacer()
                    .frame(height: 200)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения культуры
    private func saveCrop() {
        guard let quantity = Int(cropQuantity) else { return }
        
        let cropItem = FarmboardItem(
            name: "Crop", // Общее название для всех культур
            itemType: .crop,
            quantity: quantity,
            unit: unit,
            notes: ""
        )
        
        dataManager.addFarmboardItem(cropItem)
        print("✅ Добавлена культура: количество \(quantity) \(unit)")
        
        onCropSaved() // Закрываем все overlays и возвращаемся к главному экрану
    }
}

// Выбор типа животного
struct AnimalTypeSelectionView: View {
    @Binding var animalQuantity: String
    let dataManager: FarmDataManager
    let onAnimalSaved: () -> Void
    
    @State private var selectedAnimalType: AnimalType?
    @State private var showingQuantityInput = false
    
    enum AnimalType {
        case milk
        case egg
        
        var unit: String {
            switch self {
            case .milk: return "l"  // литры
            case .egg: return "pcs" // штуки
            }
        }
        
        var name: String {
            switch self {
            case .milk: return "Milk"
            case .egg: return "Egg"
            }
        }
    }
    
    // Проверка готовности формы - максимум 3 цифры и не пустое
    private var isFormValid: Bool {
        !animalQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        animalQuantity.count <= 3 && 
        animalQuantity.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Верхний отступ
                Spacer()
                    .frame(height: 40)
                
                if !showingQuantityInput {
                    // Этап выбора типа животного
                    // Иконка животного (уменьшенная)
                    Image("my_animal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                    
                    // Отступ перед кнопками
                    Spacer()
                        .frame(height: 30)
                    
                    // Кнопки выбора типа
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedAnimalType = .milk
                            showingQuantityInput = true
                        }) {
                            Image("btn_milk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            selectedAnimalType = .egg
                            showingQuantityInput = true
                        }) {
                            Image("btn_egg")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    // Этап ввода количества
                    if let animalType = selectedAnimalType {
                        // Иконка выбранного типа животного
                        Image(animalType == .milk ? "milk" : "egg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                        
                        // Отступ перед полем ввода
                        Spacer()
                            .frame(height: 40)
                        
                        // Текстовое поле для количества с единицами измерения
                        ZStack {
                            AnimalTextField(
                                placeholder: "QUANTITY",
                                text: $animalQuantity,
                                keyboardType: .numberPad,
                                isNumericOnly: true
                            )
                            
                            // Отображение единиц измерения справа
                            HStack {
                                Spacer()
                                Text(animalType.unit)
                                    .font(.custom("Chango-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    .padding(.trailing, 20)
                            }
                        }
                        .onChange(of: animalQuantity) { newValue in
                            // Ограничиваем до 3 цифр и только числа
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 3 {
                                animalQuantity = String(filtered.prefix(3))
                            } else {
                                animalQuantity = filtered
                            }
                        }
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 30)
                        
                        // Кнопка сохранения
                        Button(action: {
                            if isFormValid {
                                saveAnimal()
                            }
                        }) {
                            Image("btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Нижний отступ
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения животного
    private func saveAnimal() {
        guard let quantity = Int(animalQuantity),
              let animalType = selectedAnimalType else { return }
        
        let animalItem = FarmboardItem(
            name: animalType.name,
            itemType: .animal,
            quantity: quantity,
            unit: animalType.unit,
            notes: ""
        )
        
        dataManager.addFarmboardItem(animalItem)
        print("✅ Добавлено животное: \(animalType.name) количество \(quantity) \(animalType.unit)")
        
        onAnimalSaved() // Закрываем все overlays и возвращаемся к главному экрану
    }
}

// Выбор типа задачи
struct TaskTypeSelectionView: View {
    @Binding var taskName: String
    let dataManager: FarmDataManager
    let onTaskSaved: () -> Void
    
    // Проверка готовности формы - максимум 15 символов и не пустое
    private var isFormValid: Bool {
        !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && taskName.count <= 15
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Верхний отступ
                Spacer()
                    .frame(height: 20)
                
                // Иконка задачи (уменьшенная)
                Image("my_task")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                
                // Отступ перед полем ввода
                Spacer()
                    .frame(height: 40)
                
                // Текстовое поле для названия задачи
                AnimalTextField(
                    placeholder: "TASK NAME",
                    text: $taskName,
                    keyboardType: .default
                )
                .onChange(of: taskName) { newValue in
                    // Ограничиваем до 15 символов
                    if newValue.count > 15 {
                        taskName = String(newValue.prefix(15))
                    }
                }
                
                // Отступ перед кнопкой
                Spacer()
                    .frame(height: 30)
                
                // Кнопка сохранения
                Button(action: {
                    if isFormValid {
                        saveTask()
                    }
                }) {
                    Image("btn_save")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                        .opacity(isFormValid ? 1 : 0.5)
                }
                .disabled(!isFormValid)
                .buttonStyle(PlainButtonStyle())
                
                // Нижний отступ для клавиатуры
                Spacer()
                    .frame(height: 200)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения задачи
    private func saveTask() {
        let taskItem = FarmboardItem(
            name: taskName,
            itemType: .task,
            quantity: 1,
            unit: "pcs",
            notes: ""
        )
        
        dataManager.addFarmboardItem(taskItem)
        print("✅ Добавлена задача: \(taskName)")
        
        onTaskSaved() // Закрываем все overlays и возвращаемся к главному экрану
    }
}

// Выбор типа события
struct EventTypeSelectionView: View {
    @Binding var eventName: String
    let dataManager: FarmDataManager
    let onEventSaved: () -> Void
    
    @State private var selectedDate: Date = Date().addingTimeInterval(3600) // Минимум через час
    
    // Проверка готовности формы - максимум 15 символов и не пустое
    private var isFormValid: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        eventName.count <= 15 && 
        selectedDate > Date()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Верхний отступ
                Spacer()
                    .frame(height: 20)
                
                // Иконка события (уменьшенная)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                // Отступ перед полем ввода
                Spacer()
                    .frame(height: 30)
                
                // Текстовое поле для названия события
                AnimalTextField(
                    placeholder: "EVENT NAME",
                    text: $eventName,
                    keyboardType: .default
                )
                .onChange(of: eventName) { newValue in
                    // Ограничиваем до 15 символов
                    if newValue.count > 15 {
                        eventName = String(newValue.prefix(15))
                    }
                }
                
                // Отступ перед DatePicker
                Spacer()
                    .frame(height: 20)
                
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("DATE & TIME")
                            .font(.custom("Chango-Regular", size: 13))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                // Отступ перед кнопкой
                Spacer()
                    .frame(height: 30)
                
                // Кнопка сохранения
                Button(action: {
                    if isFormValid {
                        saveEvent()
                    }
                }) {
                    Image("btn_save")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                        .opacity(isFormValid ? 1 : 0.5)
                }
                .disabled(!isFormValid)
                .buttonStyle(PlainButtonStyle())
                
                // Нижний отступ для клавиатуры
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения события
    private func saveEvent() {
        // Запрашиваем разрешение на уведомления
        requestNotificationPermission { granted in
            if granted {
                scheduleNotification()
            }
            
            // Сохраняем событие в любом случае
            let eventItem = FarmboardItem(
                name: eventName,
                itemType: .event,
                quantity: 1,
                unit: "pcs",
                notes: "",
                scheduledDate: selectedDate
            )
            
            dataManager.addFarmboardItem(eventItem)
            print("✅ Добавлено событие: \(eventName) на \(selectedDate)")
            
            DispatchQueue.main.async {
                onEventSaved() // Закрываем все overlays и возвращаемся к главному экрану
            }
        }
    }
    
    // Запрос разрешения на уведомления
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }
    
    // Планирование уведомления
    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Farm Reminder"
        content.body = eventName
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Ошибка планирования уведомления: \(error)")
            } else {
                print("✅ Уведомление запланировано на \(selectedDate)")
            }
        }
    }
}

// Overlay для ввода деталей элемента
struct FarmboardItemDetailsOverlay: View {
    @Binding var isPresented: Bool
    let itemType: FarmboardItem.FarmboardItemType
    let cropQuantity: String
    let taskName: String
    let eventName: String
    let animalQuantity: String
    let dataManager: FarmDataManager
    
    @State private var quantity: String = ""
    @State private var unit: String = "pcs"
    @State private var notes: String = ""
    @State private var selectedDate: Date = Date()
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        switch itemType {
        case .crop:
            return !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .task:
            return !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .event:
            return !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .animal:
            return !animalQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header с кнопкой назад и заголовком
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
                    
                    Image(getHeaderImageName())
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
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 40)
                        
                        // Основная иконка
                        getMainIcon()
                            .padding(.bottom, 30)
                        
                        // Поля формы в зависимости от типа
                        VStack(spacing: 16) {
                            switch itemType {
                            case .crop:
                                AnimalTextField(
                                    placeholder: "QUANTITY",
                                    text: $quantity,
                                    keyboardType: .numberPad,
                                    isNumericOnly: true
                                )
                            case .task:
                                Text("Task: \(taskName)")
                                    .font(.custom("Chango-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            case .event:
                                Text("Event: \(eventName)")
                                    .font(.custom("Chango-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("DATE")
                                            .font(.custom("Chango-Regular", size: 13))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    DatePickerField(selectedDate: $selectedDate)
                                }
                            case .animal:
                                Text("Animal: \(animalQuantity)")
                                    .font(.custom("Chango-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 60)
                        
                        // Кнопка Save или Next
                        Button(action: {
                            saveItem()
                        }) {
                            Image(itemType == .animal ? "btn_next" : "btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        
                        // Нижний отступ для tab bar
                        Spacer()
                            .frame(height: 350)
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func getHeaderImageName() -> String {
        switch itemType {
        case .crop: return "add_crop_text"
        case .animal: return "add_animal_text"
        case .task: return "add_task_text"
        case .event: return "add_event_text"
        }
    }
    
    @ViewBuilder
    private func getMainIcon() -> some View {
        switch itemType {
        case .crop:
            Image("crop")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        case .animal:
            Image(systemName: "pawprint.fill")
                .font(.system(size: 100))
                .foregroundColor(.orange)
        case .task:
            Image(systemName: "checklist")
                .font(.system(size: 100))
                .foregroundColor(.blue)
        case .event:
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 100))
                .foregroundColor(.purple)
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения элемента
    private func saveItem() {
        let itemName: String = {
            switch itemType {
            case .crop:
                return "Crop" // Общее название для всех культур
            case .task:
                return taskName
            case .event:
                return eventName
            case .animal:
                return "Animal" // Общее название для всех животных
            }
        }()
        
        let itemQuantity: Int = {
            switch itemType {
            case .crop:
                return Int(quantity) ?? 1
            default:
                return 1
            }
        }()
        
        let item = FarmboardItem(
            name: itemName,
            itemType: itemType,
            quantity: itemQuantity,
            unit: unit,
            notes: notes
        )
        
        dataManager.addFarmboardItem(item)
        print("✅ Добавлен элемент farmboard: \(itemName) типа \(itemType.rawValue)")
        
        isPresented = false
    }
}

// Overlay для просмотра деталей элемента
struct FarmboardItemDetailOverlay: View {
    @Binding var isPresented: Bool
    let item: FarmboardItem
    let dataManager: FarmDataManager
    let onItemDeleted: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header с кнопками
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Text(item.name.uppercased())
                        .font(.custom("Chango-Regular", size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Основная карточка
                        ZStack {
                            Image("rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320)
                            
                            VStack(spacing: 12) {
                                // Иконка типа
                                Image(item.itemType.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 10)
                                
                                // Название
                                Text(item.itemType.rawValue.uppercased())
                                    .font(.custom("Chango-Regular", size: 24))
                                    .foregroundColor(.orange)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                
                                // Количество
                                VStack(spacing: 4) {
                                    Text("QUANTITY")
                                        .font(.custom("Chango-Regular", size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("\(item.quantity) \(item.unit)")
                                        .font(.custom("Chango-Regular", size: 28))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                }
                                
                                // Статус
                                Text(item.status.rawValue.uppercased())
                                    .font(.custom("Chango-Regular", size: 14))
                                    .foregroundColor(item.status.color)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    .padding(.bottom, 10)
                            }
                        }
                        
                        // Дополнительная информация
                        if !item.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("NOTES")
                                    .font(.custom("Chango-Regular", size: 14))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                
                                ZStack {
                                    Image("field_empty")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 340)
                                    
                                    HStack {
                                        Text(item.notes)
                                            .font(.custom("Chango-Regular", size: 12))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 15)
                                }
                            }
                        }
                        
                        // Дата создания
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CREATED")
                                .font(.custom("Chango-Regular", size: 14))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            ZStack {
                                Image("field_empty")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 340)
                                
                                HStack {
                                    Text(formatDate(item.createdDate))
                                        .font(.custom("Chango-Regular", size: 12))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                                    Spacer()
                                }
                                .padding(.horizontal, 15)
                            }
                        }
                        
                        // Нижний отступ
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .alert("Delete Item?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteFarmboardItem(item)
                onItemDeleted()
                isPresented = false
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#Preview("Farmboard - Empty State") {
    FarmboardView()
        .environmentObject(FarmDataManager())
}

#Preview("Farmboard - With Items") {
    let previewDataManager = FarmDataManager()
    let sampleItems = [
        // Crops для WEEKLY CROP блока
        FarmboardItem(name: "Crop", itemType: .crop, quantity: 124, unit: "kg"),
        
        // Animals для WEEKLY CROP блока
        FarmboardItem(name: "Milk", itemType: .animal, quantity: 60, unit: "l"),
        FarmboardItem(name: "Egg", itemType: .animal, quantity: 1, unit: "pcs"),
        
        // Tasks для TASKS секции (больше для демонстрации скролла)
        FarmboardItem(name: "Water Cucumbers", itemType: .task, quantity: 1, unit: "pcs"),
        FarmboardItem(name: "Clean Chicken Coop", itemType: .task, quantity: 1, unit: "pcs"),
        FarmboardItem(name: "Feed Animals", itemType: .task, quantity: 1, unit: "pcs"),
        FarmboardItem(name: "Check Plants", itemType: .task, quantity: 1, unit: "pcs"),
        
        // Events для EVENT секции с разными временами
        FarmboardItem(name: "Calf Vaccination", itemType: .event, quantity: 1, unit: "pcs", scheduledDate: Date().addingTimeInterval(3600 * 72)), // Через 3 дня
        FarmboardItem(name: "Carrot Harvest", itemType: .event, quantity: 1, unit: "pcs", scheduledDate: Date().addingTimeInterval(3600 * 24)), // Завтра
        FarmboardItem(name: "Plant Watering", itemType: .event, quantity: 1, unit: "pcs", scheduledDate: Date().addingTimeInterval(3600 * 2)) // Через 2 часа
    ]
    
    for item in sampleItems {
        previewDataManager.addFarmboardItem(item)
    }
    
    return FarmboardView()
        .environmentObject(previewDataManager)
}


#Preview("Add Task - Type Selection") {
    ZStack {
        Color.clear
        FarmboardItemTypeOverlay(
            isPresented: .constant(true),
            selectedItemType: .task,
            cropQuantity: .constant(""),
            taskName: .constant(""),
            eventName: .constant(""),
            animalQuantity: .constant(""),
            dataManager: FarmDataManager(),
            onItemTypeConfirmed: {},
            onCropSaved: {},
            onAnimalSaved: {},
            onTaskSaved: {},
            onEventSaved: {}
        )
    }
}

#Preview("Add Event - Type Selection") {
    ZStack {
        Color.clear
        FarmboardItemTypeOverlay(
            isPresented: .constant(true),
            selectedItemType: .event,
            cropQuantity: .constant(""),
            taskName: .constant(""),
            eventName: .constant(""),
            animalQuantity: .constant(""),
            dataManager: FarmDataManager(),
            onItemTypeConfirmed: {},
            onCropSaved: {},
            onAnimalSaved: {},
            onTaskSaved: {},
            onEventSaved: {}
        )
    }
}

#Preview("Add Task - Details") {
    ZStack {
        Color.clear
        FarmboardItemDetailsOverlay(
            isPresented: .constant(true),
            itemType: .task,
            cropQuantity: "",
            taskName: "Daily Feeding",
            eventName: "",
            animalQuantity: "",
            dataManager: FarmDataManager()
        )
    }
}

#Preview("Add Event - Details") {
    ZStack {
        Color.clear
        FarmboardItemDetailsOverlay(
            isPresented: .constant(true),
            itemType: .event,
            cropQuantity: "",
            taskName: "",
            eventName: "Harvest Party",
            animalQuantity: "",
            dataManager: FarmDataManager()
        )
    }
}

#Preview("Item Detail View") {
    let sampleItem = FarmboardItem(
        name: "Wheat Harvest",
        itemType: .crop,
        quantity: 150,
        unit: "kg",
        notes: "High quality winter wheat from field #3"
    )
    
    return ZStack {
        Color.clear
        FarmboardItemDetailOverlay(
            isPresented: .constant(true),
            item: sampleItem,
            dataManager: FarmDataManager(),
            onItemDeleted: {}
        )
    }
}
