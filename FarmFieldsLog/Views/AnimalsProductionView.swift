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
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("anim_prod_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                    Spacer()
                }
                .padding(.top, 20)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        AnimalsContentView(
                            dataManager: dataManager,
                        selectedAnimal: $selectedAnimal
                    )
                        .id("animals_content_\(dataManager.animals.count)")
                        Spacer()
                            .frame(height: 30)
                        Button(action: {
                            showingSpeciesSelection = true
                        }) {
                            Image("add_animal")
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
                            selectedAnimal = nil
                            showingAnimalDetailView = false
                        }
                    )
                }
            }
        )
        .onChange(of: showingAnimalDetails) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingAnimalDetailView) { isShowing in
            if !isShowing {
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
struct AnimalsContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedAnimal: Animal?
    var hasAnimals: Bool {
        !dataManager.animals.isEmpty
    }
    var body: some View {
        VStack(spacing: 0) {
            if hasAnimals {
                AnimalsSection(
                    dataManager: dataManager,
                    selectedAnimal: $selectedAnimal
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
struct AnimalsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedAnimal: Animal?
    var body: some View {
        VStack(spacing: 8) {
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
            .frame(maxHeight: 300)
        }
        .padding(.horizontal, 12)
    }
}
struct AnimalCard: View {
    let animal: Animal
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 16)
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
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
struct AnimalSpeciesSelectionOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedSpecies: Animal.AnimalSpecies?
    let onSpeciesSelected: () -> Void
    private let availableSpecies: [Animal.AnimalSpecies] = [.chicken, .cow, .sheep, .goat, .duck]
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
                VStack(spacing: 12) {
                    ForEach(availableSpecies, id: \.self) { species in
                        Button(action: {
                            selectedSpecies = species
                            onSpeciesSelected()
                        }) {
                            ZStack {
                                Image("field_empty")
                                    .resizable()
                                    .scaledToFit()
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
    private let feedingOptions = ["FEEDING", "PLAN OF FEEDING AND CARE"]
    private let careOptions = ["CARE", "CLEANING"]
    private let cleaningOptions = ["EVERY DAY", "EVERY 3 DAYS", "ONCE A WEEK", "TWICE A MONTH"]
    private var isFormValid: Bool {
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        HStack {
                            Text(selectedSpecies.rawValue.uppercased())
                                .font(.custom("Chango-Regular", size: 18))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
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
                        VStack(spacing: 16) {
                            Text("PLAN OF FEEDING AND CARE")
                                .font(.custom("Chango-Regular", size: 13))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            AnimalDropdown(
                                placeholder: "FEEDING",
                                selectedOption: $selectedFeedingPlan,
                                options: feedingOptions
                            )
                            AnimalDropdown(
                                placeholder: "CARE",
                                selectedOption: $selectedCare,
                                options: careOptions
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
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
                Spacer()
                            .frame(height: 40)
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
                    hideKeyboard()
                }
        )
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveAnimal() {
        guard let quantityValue = Int(quantity), quantityValue > 0 else {
            return
        }
        let weightValue = Double(weight) ?? 0.0
        let eggValue = Double(eggPerDay) ?? 0.0
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
        dataManager.addAnimal(newAnimal)
        isPresented = false
    }
}
struct AnimalDropdown: View {
    let placeholder: String
    @Binding var selectedOption: String
    let options: [String]
    @State private var isExpanded: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
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
                .scaledToFit()
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
                        if isNumericOnly {
                            filteredValue = newValue.filter { $0.isNumber }
                        }
                        if filteredValue.count > 20 {
                            filteredValue = String(filteredValue.prefix(20))
                        }
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
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    Text(animal.species.rawValue.uppercased())
                .font(.custom("Chango-Regular", size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: {
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        AnimalMainInfoCard(animal: animal, dataManager: dataManager)
                            .id("animal_card_\(animal.id)_\(dataManager.productionRecords.count)_\(dataManager.weightChangeRecords.count)")
                        AnimalActionButtons(
                            animal: animal,
                            onEggToday: {
                                showingAddEggOverlay = true
                            },
                            onWeightChange: {
                                showingAddWeightOverlay = true
                            }
                        )
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
                        WeightChangesSection(
                            animal: animal,
                            dataManager: dataManager,
                            onAddWeightChange: {
                                showingAddWeightOverlay = true
                            }
                        )
                        EventsSection(
                            animal: animal,
                            dataManager: dataManager,
                            onAddEvent: {
                                showingAddEventOverlay = true
                            }
                        )
                        if animal.species == .chicken || animal.species == .duck {
                            FeedingPlanSection(animal: animal)
                        }
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .overlay(
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingAddWeightOverlay) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dataManager.objectWillChange.send()
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
    private func deleteAnimal() {
        dataManager.deleteAnimal(animal)
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        onAnimalDeleted?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
        }
    }
}
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
                Text(animal.species.icon)
                    .font(.system(size: 60))
                    .padding(.top, 10)
                Text(animal.species.rawValue.uppercased())
                    .font(.custom("Chango-Regular", size: 28))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                VStack(spacing: 4) {
                    Text("TOTAL IN GROUP")
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(animal.count)")
                        .font(.custom("Chango-Regular", size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                HStack(spacing: 60) {
                    VStack(spacing: 4) {
                        Text("WEIGHT")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Text(getWeightText())
                            .font(.custom("Chango-Regular", size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
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
    private func getWeightText() -> String {
        let currentWeight = getCurrentWeight()
        return "\(Int(currentWeight)) KG"
    }
    private func getCurrentWeight() -> Double {
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
        let weightChanges = dataManager.weightChangeRecords
            .filter { $0.animalId == animal.id }
            .sorted { $0.date < $1.date }
        let totalWeightChange = weightChanges.reduce(0) { total, record in
            total + record.weightChange
        }
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
            let totalEggs = dataManager.productionRecords
                .filter { record in
                    record.animalId == animal.id &&
                    record.productType == .eggs
                }
                .reduce(0) { total, record in
                    total + record.amount
                }
            return totalEggs > 0 ? "\(Int(totalEggs)) PCS" : "0 PCS"
        case .sheep:
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
struct ProductionStatisticsSection: View {
    let title: String
    let productType: ProductionRecord.ProductType
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddProduction: () -> Void
    private var productionRecords: [ProductionRecord] {
        let filtered = dataManager.productionRecords.filter { record in
            record.animalId == animal.id && record.productType == productType
        }.sorted { $0.date > $1.date }
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
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
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
                ForEach(productionRecords.prefix(3)) { record in
                    ProductionRecordCard(record: record)
                }
            }
        }
    }
}
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
struct WeightChangesSection: View {
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddWeightChange: () -> Void
    private var weightChangeRecords: [WeightChangeRecord] {
        return dataManager.weightChangeRecords.filter { record in
            record.animalId == animal.id
        }.sorted { $0.date > $1.date }
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
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
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
                ForEach(weightChangeRecords.prefix(3)) { record in
                    WeightChangeCard(record: record)
                }
            }
        }
    }
}
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
struct EventsSection: View {
    let animal: Animal
    let dataManager: FarmDataManager
    let onAddEvent: () -> Void
    private var animalEvents: [FarmEvent] {
        return dataManager.events.filter { event in
            event.relatedAnimalId == animal.id
        }.sorted { $0.date > $1.date }
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
                ZStack {
                    Image("field_empty")
                        .resizable()
                        .scaledToFit()
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
                ForEach(animalEvents.prefix(3)) { event in
                    AnimalEventCard(event: event)
                }
            }
        }
    }
}
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
struct FeedingPlanCard: View {
    let type: String
    let description: String
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
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
struct DatePickerField: View {
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
struct AddEggProductionOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var eggCount: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasScrolled: Bool = false
    private var isFormValid: Bool {
        !eggCount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        VStack(spacing: 16) {
                            AnimalTextField(
                                placeholder: placeholderText,
                                text: $eggCount,
                                keyboardType: .numberPad,
                                isNumericOnly: true
                            )
                            DatePickerField(
                                selectedDate: $selectedDate
                            )
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 60)
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
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveEggProduction() {
        guard let count = Int(eggCount), count > 0 else { return }
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
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dataManager.objectWillChange.send()
        }
        isPresented = false
    }
}
struct AddWeightChangeOverlay: View {
    @Binding var isPresented: Bool
    let animal: Animal
    let dataManager: FarmDataManager
    @State private var weightChange: String = ""
    @State private var isWeightGain: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var hasScrolled: Bool = false
    private var isFormValid: Bool {
        !weightChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        VStack(spacing: 16) {
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
                            DatePickerField(
                                selectedDate: $selectedDate
                            )
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                            .frame(height: 60)
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
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
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
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        isPresented = false
    }
}
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
    private let availableEventTypes: [FarmEvent.EventType] = [.vaccination, .inspection]
    private var isFormValid: Bool {
        !eventDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
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
                if currentStep == .selectType {
                    VStack(spacing: 0) {
                        Text("SCHEDULE OF VACCINATIONS AND CARE")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        Spacer()
                        HStack(spacing: 20) {
                            Button {
                                selectedEventType = .vaccination
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
                                selectedEventType = .inspection
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = .enterDetails
                                }
                            } label: {
                                Image("ins1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120)
                            }
                        }
                        .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: 40)
                            Image(selectedEventType == .vaccination ? "igla" : "chel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .onAppear {
                                }
                            .padding(.bottom, 30)
                            VStack(spacing: 16) {
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
                            Spacer()
                                .frame(height: 60)
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
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
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
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        isPresented = false
    }
}
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
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: eventType.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
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
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        Image(selectedEventType == .vaccination ? "igla" : "chel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                        .padding(.bottom, 30)
                        VStack(spacing: 16) {
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
                        Spacer()
                            .frame(height: 60)
                        Button(action: {
                        }) {
                            Image("btn_next")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 55)
                        }
                        .padding(.horizontal, 20)
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
