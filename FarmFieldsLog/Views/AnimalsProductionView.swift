import SwiftUI

struct AnimalsProductionView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingSpeciesSelection = false
    @State private var showingAnimalDetails = false
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
        .sheet(item: $selectedAnimal) { animal in
            AnimalDetailView(animal: animal)
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

// MARK: - Animal Detail View
struct AnimalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let animal: Animal
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                        Button("Close") {
                            dismiss()
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding()
                    
                        Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text(animal.species.icon)
                        .font(.system(size: 80))
                    
                    Text(animal.species.rawValue.uppercased())
                        .font(.custom("Chango-Regular", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3)
                    
                    Text("DETAIL VIEW - COMING SOON")
                        .font(.custom("Chango-Regular", size: 16))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                
                Spacer()
            }
        }
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
