import SwiftUI

struct AnimalsProductionView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingSpeciesSelection = false
    @State private var showingAnimalDetails = false
    @State private var showingAnimalDetailView = false
    @State private var selectedSpecies: Animal.AnimalSpecies?
    @State private var selectedAnimal: Animal?
    
    var hasAnimals: Bool {
        !dataManager.animals.isEmpty
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
                    Image("anim_prod_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                    Spacer()
                }
                .padding(.top, 20)
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 20)
                        
                        // Контент животных
                        AnimalsContentView(
                            dataManager: dataManager,
                        selectedAnimal: $selectedAnimal
                    )
                        .id("animals_content_\(dataManager.animals.count)")
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 30)
                        
                        // Кнопка Add animal
                        Button(action: {
                            showingSpeciesSelection = true
                        }) {
                            Image("add_animal")
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
            // Overlays
            Group {
                if showingSpeciesSelection {
                    AnimalSpeciesSelectionOverlay(
                        isPresented: $showingSpeciesSelection,
                        selectedSpecies: $selectedSpecies,
                        onSpeciesSelected: {
                            showingSpeciesSelection = false
                            showingAnimalDetails = true
                        }
                    )
                } else if showingAnimalDetails {
                    AnimalDetailsOverlay(
                        isPresented: $showingAnimalDetails,
                        selectedSpecies: selectedSpecies ?? .chicken,
                        dataManager: dataManager
                    )
                } else if showingAnimalDetailView, let animal = selectedAnimal {
                    AnimalDetailOverlay(
                        isPresented: $showingAnimalDetailView,
                        animal: animal,
                        dataManager: dataManager,
                        onAnimalDeleted: {
                            // Reset state after animal deletion
                            selectedAnimal = nil
                            showingAnimalDetailView = false
                        }
                    )
                }
            }
        )
        .onChange(of: showingAnimalDetails) { isShowing in
            if !isShowing {
                // Когда overlay закрывается, принудительно обновляем UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingAnimalDetailView) { isShowing in
            if !isShowing {
                // Когда детальный overlay закрывается, сбрасываем selectedAnimal и обновляем UI
                selectedAnimal = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: selectedAnimal) { animal in
            if animal != nil {
                showingAnimalDetailView = true
            }
        }
    }
}

// MARK: - Animals Content View
struct AnimalsContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedAnimal: Animal?
    
    var hasAnimals: Bool {
        !dataManager.animals.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if hasAnimals {
                // Список животных
                AnimalsSection(
                    dataManager: dataManager,
                    selectedAnimal: $selectedAnimal
                )
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

// MARK: - Animals Section
struct AnimalsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedAnimal: Animal?
    
    var body: some View {
        VStack(spacing: 8) {
            // Скроллируемый список всех животных
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(dataManager.animals) { animal in
                        AnimalCard(animal: animal) {
                            selectedAnimal = animal
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

// MARK: - Animal Card
struct AnimalCard: View {
    let animal: Animal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .frame(width: 340, height: 70)
                
                HStack {
                VStack(alignment: .leading, spacing: 4) {
                        Text(animal.species.rawValue.uppercased())
                            .font(.custom("Chango-Regular", size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        
                        Text("\(animal.breed) - COUNT: \(animal.count)")
                            .font(.custom("Chango-Regular", size: 12))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(animal.healthStatus.color)
                                .frame(width: 8, height: 8)
                            
                            Text(animal.healthStatus.rawValue.uppercased())
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(animal.species.icon)
                            .font(.system(size: 24))
                        
                        if animal.isHighProducer {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 15)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Animal Species Selection Overlay
struct AnimalSpeciesSelectionOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedSpecies: Animal.AnimalSpecies?
    let onSpeciesSelected: () -> Void
    
    // Доступные виды животных (5 как на скриншоте)
    private let availableSpecies: [Animal.AnimalSpecies] = [.chicken, .cow, .sheep, .goat, .duck]
    
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
                    
                    Image("add_animal_text")
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
                        
                Spacer()
                        
                // Кнопки видов животных
                VStack(spacing: 12) {
                    ForEach(availableSpecies, id: \.self) { species in
                        Button(action: {
                            selectedSpecies = species
                            onSpeciesSelected()
                        }) {
                            ZStack {
                                Image("field_empty")
                                    .resizable()
                                    .frame(width: 340, height: 60)
                                
                                HStack {
                                    Text(species.icon)
                                        .font(.system(size: 24))
                                    
                                    Text(species.rawValue.uppercased())
                                        .font(.custom("Chango-Regular", size: 16))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

// MARK: - Animal Details Overlay
struct AnimalDetailsOverlay: View {
    @Binding var isPresented: Bool
    let selectedSpecies: Animal.AnimalSpecies
    let dataManager: FarmDataManager
    
    @State private var quantity: String = ""
    @State private var weight: String = ""
    @State private var eggPerDay: String = ""
    @State private var selectedFeedingPlan: String = "FEEDING"
    @State private var selectedCare: String = "CARE"
    @State private var selectedCleaning: String = "EVERY DAY"
    @State private var isHighProducer: Bool = false
    @State private var hasScrolled: Bool = false
    
    // Варианты кормления
    private let feedingOptions = ["FEEDING", "PLAN OF FEEDING AND CARE"]
    // Варианты ухода
    private let careOptions = ["CARE", "CLEANING"]
    // Варианты частоты очистки
    private let cleaningOptions = ["EVERY DAY", "EVERY 3 DAYS", "ONCE A WEEK", "TWICE A MONTH"]
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                    
                    Image("add_animal_text")
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
                            .frame(height: 20)
                        
                        // Заголовок с типом животного
                        HStack {
                            Text(selectedSpecies.rawValue.uppercased())
                                .font(.custom("Chango-Regular", size: 18))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        
                        // Основные поля
                        VStack(spacing: 16) {
                            AnimalTextField(
                                placeholder: "QUANTITY",
                                text: $quantity,
                                keyboardType: .numberPad,
                                isNumericOnly: true
                            )
                            
                            AnimalTextField(
                                placeholder: "WEIGHT",
                                text: $weight,
                                keyboardType: .decimalPad,
                                unit: dataManager.settings.selectedPrimaryUnit.shortName
                            )
                            
                            if selectedSpecies == .chicken || selectedSpecies == .duck {
                                AnimalTextField(
                                    placeholder: "EGG (PER DAY)",
                                    text: $eggPerDay,
                                    keyboardType: .numberPad,
                                    isNumericOnly: true
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // План кормления и ухода
                        VStack(spacing: 16) {
                            Text("PLAN OF FEEDING AND CARE")
                                .font(.custom("Chango-Regular", size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            // FEEDING
                            AnimalDropdown(
                                placeholder: "FEEDING",
                                selectedOption: $selectedFeedingPlan,
                                options: feedingOptions
                            )
                            
                            // CARE
                            AnimalDropdown(
                                placeholder: "CARE",
                                selectedOption: $selectedCare,
                                options: careOptions
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Частота очистки
                        VStack(spacing: 16) {
                            Text("CLEANING")
                                .font(.custom("Chango-Regular", size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            VStack(spacing: 8) {
                                ForEach(cleaningOptions, id: \.self) { option in
                                    Button(action: {
                                        selectedCleaning = option
                                    }) {
                    HStack {
                                            Text(option)
                                                .font(.custom("Chango-Regular", size: 14))
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(selectedCleaning == option ? .blue.opacity(0.8) : .black.opacity(0.3))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // High Productivity Bird
                        HStack {
                            Button(action: {
                                isHighProducer.toggle()
                            }) {
                                HStack {
                                    Image(systemName: isHighProducer ? "checkmark.square.fill" : "square")
                                        .foregroundColor(.white)
                                    
                                    Text("HIGH PRODUCTIVITY BIRD")
                                        .font(.custom("Chango-Regular", size: 14))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    
                Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Отступ перед кнопкой
                Spacer()
                            .frame(height: 40)
                        
                        // Кнопка SAVE
                        Button(action: {
                            saveAnimal()
                        }) {
                            Image("btn_save")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                                .opacity(isFormValid ? 1 : 0.5)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        
                        // Нижний отступ для tab bar
                        Spacer()
                            .frame(height: 200)
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Закрываем dropdown'ы при тапе на пустое место
                    hideKeyboard()
                }
        )
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения животного
    private func saveAnimal() {
        guard let quantityValue = Int(quantity), quantityValue > 0 else {
            print("❌ Ошибка: Некорректное количество животных")
            return
        }
        
        let weightValue = Double(weight) ?? 0.0
        let eggValue = Double(eggPerDay) ?? 0.0
        
        // Формируем детальную информацию
        var detailedNotes = "Type: \(selectedSpecies.rawValue)"
        if weightValue > 0 {
            detailedNotes += ", Weight: \(weightValue) \(dataManager.settings.selectedPrimaryUnit.shortName)"
        }
        if eggValue > 0 {
            detailedNotes += ", Eggs per day: \(eggValue)"
        }
        detailedNotes += ", Feeding: \(selectedFeedingPlan), Care: \(selectedCare), Cleaning: \(selectedCleaning)"
        
        let newAnimal = Animal(
            species: selectedSpecies,
            breed: selectedSpecies.rawValue,
            name: nil,
            count: quantityValue,
            age: "",
            healthStatus: .good,
            lastVaccination: nil,
            nextVaccination: nil,
            notes: detailedNotes,
            isHighProducer: isHighProducer
        )
        
        print("✅ Сохраняем животное: \(selectedSpecies.rawValue), количество: \(quantityValue)")
        dataManager.addAnimal(newAnimal)
        print("✅ Всего животных в базе: \(dataManager.animals.count)")
        
        isPresented = false
    }
}

// MARK: - Animal Dropdown
struct AnimalDropdown: View {
    let placeholder: String
    @Binding var selectedOption: String
    let options: [String]
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main dropdown button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .frame(width: 340, height: 50)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    
                    HStack {
                        Text(selectedOption.isEmpty ? placeholder : selectedOption)
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(selectedOption.isEmpty ? .gray : .white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown options
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.custom("Chango-Regular", size: 14))
                                    .foregroundColor(.white)
                        Spacer()
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(selectedOption == option ? 
                                        Color.blue.opacity(0.6) : 
                                        Color.black.opacity(0.8))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(width: 340)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.black.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.top, -10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Animal Text Field
struct AnimalTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var unit: String = ""
    var isNumericOnly: Bool = false
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .frame(width: 340, height: 50)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    
                    HStack {
                TextField("", text: $text)
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
                        
                        // Ограничение символов (20 символов максимум)
                        if filteredValue.count > 20 {
                            filteredValue = String(filteredValue.prefix(20))
                        }
                        
                        // Обновляем только если значение изменилось
                        if filteredValue != newValue {
                            text = filteredValue
                }
            }
            
            Spacer()
            
                if !unit.isEmpty {
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

// MARK: - Animal Detail Overlay
struct AnimalDetailOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    let onAnimalDeleted: (() -> Void)?
    @State private var showingAddEggOverlay = false
    @State private var showingAddWeightOverlay = false
    @State private var showingAddEventOverlay = false
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
                    
                    // Название животного
                    Text(animal.species.rawValue.uppercased())
                .font(.custom("Chango-Regular", size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            // TODO: Edit action
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.yellow)
                                .hidden()
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Основная карточка с информацией о животном
                        AnimalMainInfoCard(animal: animal, dataManager: dataManager)
                            .id("animal_card_\(animal.id)_\(dataManager.productionRecords.count)_\(dataManager.weightChangeRecords.count)")
                        
                        // Кнопки действий
                        AnimalActionButtons(
                            animal: animal,
                            onEggToday: {
                                showingAddEggOverlay = true
                            },
                            onWeightChange: {
                                showingAddWeightOverlay = true
                            }
                        )
                        
                        // Статистика продукции
                        if animal.species == .cow {
                            ProductionStatisticsSection(
                                title: "COLLECTING MILK",
                                productType: .milk,
                                animal: animal,
                                dataManager: dataManager,
                                onAddProduction: {
                                    showingAddEggOverlay = true
                                }
                            )
                        } else if animal.species == .sheep {
                            ProductionStatisticsSection(
                                title: "COLLECTING WOOL", 
                                productType: .wool,
                                animal: animal,
                                dataManager: dataManager,
                                onAddProduction: {
                                    showingAddEggOverlay = true
                                }
                            )
                        } else if animal.species == .chicken || animal.species == .duck {
                            ProductionStatisticsSection(
                                title: "COLLECTING EGGS",
                                productType: .eggs,
                                animal: animal,
                                dataManager: dataManager,
                                onAddProduction: {
                                    showingAddEggOverlay = true
                                }
                            )
                        }
                        
                        // Изменения веса
                        WeightChangesSection(
                            animal: animal,
                            dataManager: dataManager,
                            onAddWeightChange: {
                                showingAddWeightOverlay = true
                            }
                        )
                        
                        // События (вакцинация)
                        EventsSection(
                            animal: animal,
                            dataManager: dataManager,
                            onAddEvent: {
                                showingAddEventOverlay = true
                            }
                        )
                        
                        // План кормления и ухода (только для птиц)
                        if animal.species == .chicken || animal.species == .duck {
                            FeedingPlanSection(animal: animal)
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
        .overlay(
            // Add Overlays
            Group {
                if showingAddEggOverlay {
                    AddEggProductionOverlay(
                        isPresented: $showingAddEggOverlay,
                        animal: animal,
                        dataManager: dataManager
                    )
                } else if showingAddWeightOverlay {
                    AddWeightChangeOverlay(
                        isPresented: $showingAddWeightOverlay,
                        animal: animal,
                        dataManager: dataManager
                    )
                } else if showingAddEventOverlay {
                    AddAnimalEventOverlay(
                        isPresented: $showingAddEventOverlay,
                        animal: animal,
                        dataManager: dataManager
                    )
                }
            }
        )
        .onChange(of: showingAddEggOverlay) { isShowing in
            if !isShowing {
                // Когда egg overlay закрывается, принудительно обновляем UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dataManager.objectWillChange.send()
                    print("🔄 Обновление после закрытия egg overlay")
                }
            }
        }
        .onChange(of: showingAddWeightOverlay) { isShowing in
            if !isShowing {
                // Когда weight overlay закрывается, принудительно обновляем UI
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dataManager.objectWillChange.send()
                    print("🔄 Обновление после закрытия weight overlay")
                }
            }
        }
        .alert("Delete Animal?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAnimal()
            }
        } message: {
            Text("This action cannot be undone. All production, weight, and event records for this animal will be permanently deleted.")
        }
    }
    
    // MARK: - Delete Animal Function
    private func deleteAnimal() {
        // Delete animal from dataManager
        dataManager.deleteAnimal(animal)
        
        // Force UI update
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        
        // Call callback to notify parent view
        onAnimalDeleted?()
        
        // Close overlay and return to animals list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
        }
    }
}

// MARK: - Animal Main Info Card
struct AnimalMainInfoCard: View {
    let animal: Animal
    @ObservedObject var dataManager: FarmDataManager
    
    var body: some View {
        ZStack {
            Image("rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 320)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack(spacing: 12) {
                // Верхний ряд - иконка животного
                Text(animal.species.icon)
                    .font(.system(size: 60))
                    .padding(.top, 10)
                
                // Название животного  
                Text(animal.species.rawValue.uppercased())
                    .font(.custom("Chango-Regular", size: 28))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                
                // TOTAL IN GROUP
                VStack(spacing: 4) {
                    Text("TOTAL IN GROUP")
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(animal.count)")
                        .font(.custom("Chango-Regular", size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                
                // Нижний ряд - вес и продукция
                HStack(spacing: 60) {
                    // Левая колонка - WEIGHT
                    VStack(spacing: 4) {
                        Text("WEIGHT")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(getWeightText())
                            .font(.custom("Chango-Regular", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                    
                    // Правая колонка - PRODUCTION
                    VStack(spacing: 4) {
                        Text(getProductionLabel())
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(getProductionText())
                            .font(.custom("Chango-Regular", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(20)
        }
    }
    
    // Вспомогательные функции для отображения данных
    private func getWeightText() -> String {
        // Получаем текущий вес с учетом всех изменений
        let currentWeight = getCurrentWeight()
        return "\(Int(currentWeight)) KG"
    }
    
    private func getCurrentWeight() -> Double {
        // Базовый вес одного животного по виду
        let baseWeight: Double = {
            switch animal.species {
            case .cow: return 500.0
            case .sheep: return 60.0
            case .goat: return 40.0
            case .pig: return 100.0
            case .chicken: return 2.0
            case .duck: return 3.0
            case .turkey: return 8.0
            case .rabbit: return 2.0
            }
        }()
        
        // Получаем все изменения веса для этого животного
        let weightChanges = dataManager.weightChangeRecords
            .filter { $0.animalId == animal.id }
            .sorted { $0.date < $1.date } // Сортируем по дате
        
        // Считаем итоговый вес с учетом всех изменений
        let totalWeightChange = weightChanges.reduce(0) { total, record in
            total + record.weightChange
        }
        
        // Базовый вес всей группы + изменения
        let totalBaseWeight = baseWeight * Double(animal.count)
        return totalBaseWeight + totalWeightChange
    }
    
    private func getProductionLabel() -> String {
        switch animal.species {
        case .cow: return "MILK"
        case .chicken, .duck, .turkey: return "EGGS"
        case .sheep: return "WOOL"
        case .goat: return "MILK"
        default: return "PRODUCTION"
        }
    }
    
    private func getProductionText() -> String {
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? today
        
        switch animal.species {
        case .cow, .goat:
            // Подсчитываем молоко за сегодня
            let todayMilk = dataManager.productionRecords
                .filter { record in
                    record.animalId == animal.id &&
                    record.productType == .milk &&
                    record.date >= startOfToday &&
                    record.date < endOfToday
                }
                .reduce(0) { total, record in
                    total + record.amount
                }
            
            // Если нет записей за сегодня, показываем последнюю запись
            if todayMilk == 0 {
                let lastMilk = dataManager.productionRecords
                    .filter { record in
                        record.animalId == animal.id &&
                        record.productType == .milk
                    }
                    .sorted { $0.date > $1.date }
                    .first?.amount ?? 0
                return lastMilk > 0 ? "\(Int(lastMilk)) L" : "0 L"
            }
            
            return "\(Int(todayMilk)) L"
            
        case .chicken, .duck, .turkey:
            // Подсчитываем ВСЕ яйца для этого животного (общая сумма)
            let totalEggs = dataManager.productionRecords
                .filter { record in
                    record.animalId == animal.id &&
                    record.productType == .eggs
                }
                .reduce(0) { total, record in
                    total + record.amount
                }
            
            // Добавляем отладочную информацию
            print("🐔 DEBUG CARD: animalId = \(animal.id)")
            print("🥚 DEBUG CARD: Общая сумма яиц = \(totalEggs)")
            print("🥚 DEBUG CARD: Всего записей в dataManager = \(dataManager.productionRecords.count)")
            
            return totalEggs > 0 ? "\(Int(totalEggs)) PCS" : "0 PCS"
            
        case .sheep:
            // Подсчитываем шерсть за всё время
            let totalWool = dataManager.productionRecords
                .filter { record in
                    record.animalId == animal.id &&
                    record.productType == .wool
                }
                .reduce(0) { total, record in
                    total + record.amount
                }
            return totalWool > 0 ? "\(Int(totalWool)) KG" : "0 KG"
            
        default:
            return "—"
        }
    }
}

// MARK: - Animal Action Buttons
struct AnimalActionButtons: View {
    let animal: Animal
    let onEggToday: () -> Void
    let onWeightChange: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            if animal.species == .chicken || animal.species == .duck {
                ActionButton(title: "Egg Today", color: .orange, action: onEggToday)
                ActionButton(title: "Weight change", color: .orange, action: onWeightChange)
            } else {
                ActionButton(title: "Add Production", color: .orange, action: onEggToday)
                ActionButton(title: "Weight change", color: .orange, action: onWeightChange)
            }
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Chango-Regular", size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(color)
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}

// MARK: - Production Statistics Section
struct ProductionStatisticsSection: View {
    let title: String
    let productType: ProductionRecord.ProductType
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddProduction: () -> Void
    
    // Фильтруем записи продукции для конкретного животного и типа продукции
    private var productionRecords: [ProductionRecord] {
        let filtered = dataManager.productionRecords.filter { record in
            record.animalId == animal.id && record.productType == productType
        }.sorted { $0.date > $1.date } // Сортируем по дате, новые сверху
        
        // Добавляем отладочную информацию
        print("📊 DEBUG SECTION: \(title)")
        print("📊 DEBUG SECTION: animalId = \(animal.id)")
        print("📊 DEBUG SECTION: productType = \(productType)")
        print("📊 DEBUG SECTION: записей найдено = \(filtered.count)")
        for (index, record) in filtered.enumerated() {
            print("📊 DEBUG SECTION: запись \(index): \(record.amount) \(record.unit) на \(record.date)")
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.custom("Chango-Regular", size: 14))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                
                Spacer()
                
                Button(action: {
                    onAddProduction()
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                }
            }
            
            if productionRecords.isEmpty {
                // Пустое состояние
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TAP PLUS")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            
                            Text("ADD YOUR FIRST RECORD")
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            } else {
                // Показываем записи продукции
                ForEach(productionRecords.prefix(3)) { record in
                    ProductionRecordCard(record: record)
                }
            }
        }
    }
}

// MARK: - Production Record Card
struct ProductionRecordCard: View {
    let record: ProductionRecord
    
    private var formattedAmount: String {
        let amount = String(format: "%.0f", record.amount)
        switch record.productType {
        case .eggs:
            return "\(amount) EGGS"
        case .milk:
            return "\(amount) L MILK" 
        case .wool:
            return "\(amount) KG WOOL"
        case .meat:
            return "\(amount) KG MEAT"
        case .honey:
            return "\(amount) KG HONEY"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: record.date)
    }
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedAmount)
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    Text(formattedDate)
                        .font(.custom("Chango-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Weight Changes Section
struct WeightChangesSection: View {
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddWeightChange: () -> Void
    
    // Фильтруем записи изменения веса для конкретного животного
    private var weightChangeRecords: [WeightChangeRecord] {
        return dataManager.weightChangeRecords.filter { record in
            record.animalId == animal.id
        }.sorted { $0.date > $1.date } // Сортируем по дате, новые сверху
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("WEIGHT CHANGES")
                    .font(.custom("Chango-Regular", size: 14))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                
                Spacer()
                
                Button(action: {
                    onAddWeightChange()
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                }
            }
            
            if weightChangeRecords.isEmpty {
                // Пустое состояние
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TAP PLUS")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            
                            Text("ADD WEIGHT CHANGE")
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            } else {
                // Показываем записи изменения веса
                ForEach(weightChangeRecords.prefix(3)) { record in
                    WeightChangeCard(record: record)
                }
            }
        }
    }
}

// MARK: - Weight Change Card
struct WeightChangeCard: View {
    let record: WeightChangeRecord
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: record.date)
    }
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
                    
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.formattedChange)
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    Text(formattedDate)
                        .font(.custom("Chango-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Events Section
struct EventsSection: View {
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddEvent: () -> Void
    
    // Фильтруем события для конкретного животного
    private var animalEvents: [FarmEvent] {
        return dataManager.events.filter { event in
            event.relatedAnimalId == animal.id
        }.sorted { $0.date > $1.date } // Сортируем по дате, новые сверху
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("EVENT")
                    .font(.custom("Chango-Regular", size: 14))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                
                Spacer()
                
                Button(action: {
                    onAddEvent()
                }) {
                    Image("my_plus")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                }
            }
            
            if animalEvents.isEmpty {
                // Пустое состояние
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TAP PLUS")
                                .font(.custom("Chango-Regular", size: 12))
                                .foregroundColor(.yellow)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            
                            Text("ADD YOUR FIRST EVENT")
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                }
            } else {
                // Показываем события животного
                ForEach(animalEvents.prefix(3)) { event in
                    AnimalEventCard(event: event)
                }
            }
        }
    }
}

// MARK: - Animal Event Card  
struct AnimalEventCard: View {
    let event: FarmEvent
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: event.date)
    }
    
    private var statusText: String {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(event.date, inSameDayAs: today) {
            return "TODAY"
        } else if event.date < today {
            return "COMPLETED"
        } else {
            let daysUntil = calendar.dateComponents([.day], from: today, to: event.date).day ?? 0
            return "IN \(max(daysUntil, 0)) DAYS"
        }
    }
    
    private var statusColor: Color {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(event.date, inSameDayAs: today) {
            return .orange
        } else if event.date < today {
            return .green
        } else {
            return .blue
        }
    }
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.eventType.rawValue.uppercased())
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(statusText)
                            .font(.custom("Chango-Regular", size: 10))
                            .foregroundColor(statusColor)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                    
                    Text(event.description)
                        .font(.custom("Chango-Regular", size: 8))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Feeding Plan Section
struct FeedingPlanSection: View {
    let animal: Animal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PLAN OF FEEDING AND CARE")
                .font(.custom("Chango-Regular", size: 14))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
            
            FeedingPlanCard(
                type: "FEEDING",
                description: "MORNING - GRAIN, EVENING - COMBINE FOOD"
            )
            
            FeedingPlanCard(
                type: "CARE",
                description: "CHECK-IN EVERY MORNING"
            )
        }
    }
}

// MARK: - Feeding Plan Card
struct FeedingPlanCard: View {
    let type: String
    let description: String
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(type)
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(description)
                        .font(.custom("Chango-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                }
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Date Picker Field
struct DatePickerField: View {
    @Binding var selectedDate: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение для текстфилда
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .tint(.white)
                    .colorScheme(.dark) // Темная схема для лучшей видимости
                
                Spacer()
                
                Text(formattedDate)
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2) // Тень для лучшей читаемости
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        }
    }
}

// MARK: - Add Egg Production Overlay
struct AddEggProductionOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var eggCount: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasScrolled: Bool = false
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !eggCount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Заголовок в зависимости от животного
    private var overlayTitle: String {
        switch animal.species {
        case .chicken, .duck:
            return "ADD EGG PRODUCTION"
        case .cow:
            return "ADD MILK PRODUCTION"
        case .sheep:
            return "ADD WOOL PRODUCTION"
        default:
            return "ADD PRODUCTION"
        }
    }
    
    // Placeholder в зависимости от животного
    private var placeholderText: String {
        switch animal.species {
        case .chicken, .duck:
            return "NUMBER OF EGGS"
        case .cow:
            return "LITERS OF MILK"
        case .sheep:
            return "KG OF WOOL"
        default:
            return "AMOUNT"
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
                    
                    Text(overlayTitle)
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
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
                        
                        // Поля формы
                        VStack(spacing: 16) {
                            AnimalTextField(
                                placeholder: placeholderText,
                                text: $eggCount,
                                keyboardType: .numberPad,
                                isNumericOnly: true
                            )
                            
                            // DATE
                            DatePickerField(
                                selectedDate: $selectedDate
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 60)
                        
                        // Кнопка SAVE
                        Button(action: {
                            saveEggProduction()
                        }) {
                            Image("btn_save")
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
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения продукции
    private func saveEggProduction() {
        guard let count = Int(eggCount), count > 0 else { return }
        
        // Определяем тип продукции и единицы в зависимости от животного
        let (productType, unit, productName): (ProductionRecord.ProductType, String, String) = {
            switch animal.species {
            case .chicken, .duck:
                return (.eggs, "pcs", "eggs")
            case .cow:
                return (.milk, "L", "milk")
            case .sheep:
                return (.wool, "kg", "wool")
            default:
                return (.eggs, "pcs", "production")
            }
        }()
        
        let newRecord = ProductionRecord(
            date: selectedDate,
            productType: productType,
            amount: Double(count),
            unit: unit,
            animalId: animal.id,
            notes: "\(productName.capitalized) from \(animal.species.rawValue)"
        )
        
        dataManager.addProductionRecord(newRecord)
        print("✅ Добавлена продукция: \(count) \(productName) от \(animal.species.rawValue)")
        print("🥚 DEBUG SAVE: animalId = \(animal.id)")
        print("🥚 DEBUG SAVE: amount = \(newRecord.amount)")
        print("🥚 DEBUG SAVE: date = \(newRecord.date)")
        print("🥚 DEBUG SAVE: type = \(newRecord.productType)")
        
        // Принудительно обновляем UI несколько раз
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        
        // Дополнительная задержка для обновления карточки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dataManager.objectWillChange.send()
            print("🔄 Дополнительное обновление UI")
        }
        
        isPresented = false
    }
}

// MARK: - Add Weight Change Overlay
struct AddWeightChangeOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var weightChange: String = ""
    @State private var isWeightGain: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var hasScrolled: Bool = false
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !weightChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                    
                    Text("ADD WEIGHT CHANGE")
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
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
                        
                        // Поля формы
                        VStack(spacing: 16) {
                            // Выбор прибавка/убавка веса
                            VStack(spacing: 12) {
                                Text("WEIGHT CHANGE TYPE")
                                    .font(.custom("Chango-Regular", size: 13))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                
                                HStack(spacing: 10) {
                                    Button(action: {
                                        isWeightGain = true
                                    }) {
                                        HStack {
                                            Image(systemName: isWeightGain ? "plus.circle.fill" : "plus.circle")
                                                .foregroundColor(isWeightGain ? .green : .white.opacity(0.6))
                                            Text("GAIN")
                                                .font(.custom("Chango-Regular", size: 14))
                                                .foregroundColor(isWeightGain ? .green : .white.opacity(0.6))
                                        }
                                        .padding()
                                        .background(
                                            Image("my_tab")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 80)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        isWeightGain = false
                                    }) {
                                        HStack {
                                            Image(systemName: !isWeightGain ? "minus.circle.fill" : "minus.circle")
                                                .foregroundColor(!isWeightGain ? .red : .white.opacity(0.6))
                                            Text("LOSS")
                                                .font(.custom("Chango-Regular", size: 14))
                                                .foregroundColor(!isWeightGain ? .red : .white.opacity(0.6))
                                        }
                                        .padding()
                                        .background(
                                            Image("my_tab")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 80)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            AnimalTextField(
                                placeholder: "WEIGHT AMOUNT",
                                text: $weightChange,
                                keyboardType: .decimalPad,
                                unit: dataManager.settings.selectedPrimaryUnit.shortName
                            )
                            
                            // DATE
                            DatePickerField(
                                selectedDate: $selectedDate
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 60)
                        
                        // Кнопка SAVE
                        Button(action: {
                            saveWeightChange()
                        }) {
                            Image("btn_save")
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
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения изменения веса
    private func saveWeightChange() {
        guard let weight = Double(weightChange), weight > 0 else { return }
        
        let changeAmount = isWeightGain ? weight : -weight
        
        let newRecord = WeightChangeRecord(
            animalId: animal.id,
            date: selectedDate,
            weightChange: changeAmount,
            unit: dataManager.settings.selectedPrimaryUnit.shortName,
            notes: "Weight change for \(animal.species.rawValue)"
        )
        
        dataManager.addWeightChangeRecord(newRecord)
        print("✅ Добавлено изменение веса: \(newRecord.formattedChange) для \(animal.species.rawValue)")
        
        // Принудительно обновляем UI
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        
        isPresented = false
    }
}

// MARK: - Add Animal Event Overlay
struct AddAnimalEventOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var currentStep: EventStep = .selectType
    @State private var selectedEventType: FarmEvent.EventType = .vaccination
    @State private var eventDate: Date = Date()
    @State private var eventDescription: String = ""
    @State private var hasScrolled: Bool = false
    
    enum EventStep {
        case selectType
        case enterDetails
    }
    
    // Доступные типы событий
    private let availableEventTypes: [FarmEvent.EventType] = [.vaccination, .inspection]
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !eventDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                        if currentStep == .selectType {
                            isPresented = false
                        } else {
                            currentStep = .selectType
                        }
                    }) {
                        Image("btn_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text(currentStep == .selectType ? "ADD EVENT" : (selectedEventType == .vaccination ? "ADD VACCINATION" : "ADD INSPECTION"))
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.orange)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                    
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Контент в зависимости от шага
                if currentStep == .selectType {
                    // Шаг 1: Выбор типа события
                    VStack(spacing: 0) {
                        // Заголовок
                        Text("SCHEDULE OF VACCINATIONS AND CARE")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        
                        Spacer()
                        
                        // Кнопки типов событий
                        HStack(spacing: 20) {
                            Button {
                                selectedEventType = .vaccination // Устанавливаем тип
                                print("🔧 DEBUG: Выбрана вакцинация - selectedEventType = \(selectedEventType)")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = .enterDetails
                                }
                            } label: {
                                Image("vac1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120)
                            }
                            Button {
                                selectedEventType = .inspection // Устанавливаем тип
                                print("🔧 DEBUG: Выбрана инспекция - selectedEventType = \(selectedEventType)")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = .enterDetails
                                }
                            } label: {
                                Image("ins1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120)
                            }
//                            ForEach(availableEventTypes, id: \.self) { eventType in
//                                EventTypeButton(
//                                    eventType: eventType,
//                                    isSelected: selectedEventType == eventType,
//                                    action: {
//                                        selectedEventType = eventType
//                                        // Переходим к следующему шагу
//                                        withAnimation(.easeInOut(duration: 0.3)) {
//                                            currentStep = .enterDetails
//                                        }
//                                    }
//                                )
//                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                        
                    }
                } else {
                    // Шаг 2: Ввод деталей
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Верхний отступ
                            Spacer()
                                .frame(height: 40)
                            
                                   // Иконка события
                            Image(selectedEventType == .vaccination ? "igla" : "chel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .onAppear {
                                    print("🖼️ DEBUG ICON: Отображается иконка - \(selectedEventType == .vaccination ? "igla" : "chel") для события \(selectedEventType)")
                                }

                            .padding(.bottom, 30)
                            
                            // Поля формы
                            VStack(spacing: 16) {
                                // DATE
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("DATE")
                                            .font(.custom("Chango-Regular", size: 13))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    DatePickerField(selectedDate: $eventDate)
                                }
                                
                                // DETAILS
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("DETAILS")
                                            .font(.custom("Chango-Regular", size: 13))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    AnimalTextField(
                                        placeholder: getPlaceholderText(),
                                        text: $eventDescription,
                                        keyboardType: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Отступ перед кнопкой
                            Spacer()
                                .frame(height: 60)
                            
                            // Кнопка Next
                            Button(action: {
                                saveEvent()
                            }) {
                                Image("btn_next")
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
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Получение placeholder текста
    private func getPlaceholderText() -> String {
        switch selectedEventType {
        case .vaccination:
            return "NEWCASTLE DISEASE, 2 DOSES"
        case .inspection:
            return "GENERAL HEALTH CHECK"
        default:
            return "EVENT DETAILS"
        }
    }
    
    // Функция сохранения события
    private func saveEvent() {
        let newEvent = FarmEvent(
            title: selectedEventType.rawValue,
            description: eventDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            date: eventDate,
            eventType: selectedEventType,
            isCompleted: false,
            reminderDate: eventDate,
            relatedAnimalId: animal.id
        )
        
        dataManager.addEvent(newEvent)
        print("✅ Добавлено событие: \(selectedEventType.rawValue) для \(animal.species.rawValue)")
        print("🔧 DEBUG SAVE EVENT: selectedEventType = \(selectedEventType)")
        print("🔧 DEBUG SAVE EVENT: newEvent.eventType = \(newEvent.eventType)")
        
        // Принудительно обновляем UI
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        
        isPresented = false
    }
}

// MARK: - Event Type Button
struct EventTypeButton: View {
    let eventType: FarmEvent.EventType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("vac1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 103)
                
                HStack(spacing: 15) {
                    // Иконка события
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: eventType.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Название события
                    Text(eventType.rawValue.uppercased())
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview("Add Animal Event - Step 1") {
    let previewDataManager = FarmDataManager()
    let sampleAnimal = Animal(
        species: .chicken,
        breed: "Rhode Island Red",
        name: nil,
        count: 21,
        age: "2 years",
        healthStatus: .excellent,
        lastVaccination: nil,
        nextVaccination: nil,
        notes: "High egg production",
        isHighProducer: true
    )
    
    return ZStack {
        Color.clear
        AddAnimalEventOverlay(
            isPresented: .constant(true),
            animal: sampleAnimal,
            dataManager: previewDataManager
        )
    }
}

#Preview("Add Animal Event - Step 2") {
    let previewDataManager = FarmDataManager()
    let sampleAnimal = Animal(
        species: .chicken,
        breed: "Rhode Island Red",
        name: nil,
        count: 21,
        age: "2 years",
        healthStatus: .excellent,
        lastVaccination: nil,
        nextVaccination: nil,
        notes: "High egg production",
        isHighProducer: true
    )
    
    return ZStack {
        Color.clear
        AddAnimalEventOverlayStep2Preview(
            animal: sampleAnimal,
            dataManager: previewDataManager
        )
    }
}

#Preview("Animals & Production - Empty State") {
    AnimalsProductionView()
        .environmentObject(FarmDataManager.shared)
}

#Preview("Animals & Production - With Animals") {
    // Создаем dataManager с моковыми данными только для preview
    let previewDataManager = FarmDataManager(withSampleData: true)
    
    return AnimalsProductionView()
        .environmentObject(previewDataManager)
}

#Preview("Animal Species Selection") {
    AnimalsProductionView()
        .environmentObject(FarmDataManager())
        .overlay(
            AnimalSpeciesSelectionOverlay(
                isPresented: .constant(true),
                selectedSpecies: .constant(nil),
                onSpeciesSelected: {}
            )
        )
}

#Preview("Animal Details Overlay") {
    let previewDataManager = FarmDataManager()
    return AnimalsProductionView()
        .environmentObject(previewDataManager)
        .overlay(
            AnimalDetailsOverlay(
                isPresented: .constant(true),
                selectedSpecies: .chicken,
                dataManager: previewDataManager
            )
        )
}

#Preview("Animal Detail View") {
    let previewDataManager = FarmDataManager(withSampleData: true)
    let sampleAnimal = Animal(
        species: .chicken,
        breed: "Rhode Island Red",
        name: nil,
        count: 12,
        age: "2 years",
        healthStatus: .excellent,
        lastVaccination: nil,
        nextVaccination: nil,
        notes: "High egg production",
        isHighProducer: true
    )
    
    return AnimalsProductionView()
        .environmentObject(previewDataManager)
        .overlay(
            AnimalDetailOverlay(
                isPresented: .constant(true),
                animal: sampleAnimal,
                dataManager: previewDataManager,
                onAnimalDeleted: nil
            )
        )
}

// MARK: - Preview Helper for Step 2
struct AddAnimalEventOverlayStep2Preview: View {
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var currentStep: AddAnimalEventOverlay.EventStep = .enterDetails
    @State private var selectedEventType: FarmEvent.EventType = .vaccination
    @State private var eventDate: Date = Date()
    @State private var eventDescription: String = "NEWCASTLE DISEASE, 2 DOSES"
    @State private var hasScrolled: Bool = false
    
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
                        // Preview action
                    }) {
                        Image("btn_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("ADD VACCINATION")
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.orange)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    
                    Spacer()
                    
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Шаг 2: Ввод деталей
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 40)
                        
                        // Иконка события
                        Image(selectedEventType == .vaccination ? "igla" : "chel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                        .padding(.bottom, 30)
                        
                        // Поля формы
                        VStack(spacing: 16) {
                            // DATE
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("DATE")
                                        .font(.custom("Chango-Regular", size: 13))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                DatePickerField(selectedDate: $eventDate)
                            }
                            
                            // DETAILS
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("DETAILS")
                                        .font(.custom("Chango-Regular", size: 13))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                AnimalTextField(
                                    placeholder: "NEWCASTLE DISEASE, 2 DOSES",
                                    text: $eventDescription,
                                    keyboardType: .default
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 60)
                        
                        // Кнопка Next
                        Button(action: {
                            // Preview action
                        }) {
                            Image("btn_next")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                        }
                        .padding(.horizontal, 20)
                        
                        // Нижний отступ для tab bar
                        Spacer()
                            .frame(height: 350)
                    }
                }
            }
        }
    }
}

#Preview("Event Type Buttons") {
    VStack(spacing: 20) {
        EventTypeButton(
            eventType: .vaccination,
            isSelected: true,
            action: { }
        )
        
        EventTypeButton(
            eventType: .inspection,
            isSelected: false,
            action: { }
        )
    }
    .padding(40)
    .background(
        Image("background")
            .resizable()
            .ignoresSafeArea(.all)
    )
}
