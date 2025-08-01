import SwiftUI

struct PlantingCycleView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingCropSelection = false
    @State private var showingCropDetails = false
    @State private var showingCropDetailView = false
    @State private var selectedCropType: Crop.CropType?
    @State private var selectedCrop: Crop?
    
    var hasCrops: Bool {
        !dataManager.crops.isEmpty
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
                    // Пока используем текст, позже можно добавить изображение заголовка
                    Image("plant_cicly_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                    Spacer()
                }
                .padding(.top, 20)
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Верхний отступ
                        Spacer()
                            .frame(height: 20)
                        
                        // Контент растений
                        CropsContentView(
                            dataManager: dataManager,
                            selectedCrop: $selectedCrop
                        )
                        .id("crops_content_\(dataManager.crops.count)")
                        
                        // Отступ перед кнопкой
                        Spacer()
                            .frame(height: 30)
                        
                        // Кнопка Add crop
                        Button(action: {
                            showingCropSelection = true
                        }) {
                            Image("btn_add_crop")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 54)
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
                if showingCropSelection {
                    CropTypeSelectionOverlay(
                        isPresented: $showingCropSelection,
                        selectedCropType: $selectedCropType,
                        onCropTypeSelected: {
                            showingCropSelection = false
                            showingCropDetails = true
                        }
                    )
                } else if showingCropDetails {
                    CropDetailsOverlay(
                        isPresented: $showingCropDetails,
                        selectedCropType: selectedCropType ?? .vegetables,
                        dataManager: dataManager
                    )
                } else if showingCropDetailView, let crop = selectedCrop {
                    CropDetailOverlay(
                        isPresented: $showingCropDetailView,
                        crop: crop,
                        dataManager: dataManager,
                        onCropDeleted: {
                            selectedCrop = nil
                            showingCropDetailView = false
                        }
                    )
                }
            }
        )
        .onChange(of: showingCropDetails) { isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: showingCropDetailView) { isShowing in
            if !isShowing {
                selectedCrop = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dataManager.objectWillChange.send()
                }
            }
        }
        .onChange(of: selectedCrop) { crop in
            if crop != nil {
                showingCropDetailView = true
            }
        }
    }
}

// MARK: - Crops Content View
struct CropsContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedCrop: Crop?
    
    var hasCrops: Bool {
        !dataManager.crops.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if hasCrops {
                // Список растений
                CropsSection(
                    dataManager: dataManager,
                    selectedCrop: $selectedCrop
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

// MARK: - Crops Section
struct CropsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedCrop: Crop?
    
    var body: some View {
        VStack(spacing: 8) {
            // Скроллируемый список всех растений
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(dataManager.crops) { crop in
                        CropCard(crop: crop) {
                            selectedCrop = crop
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

// MARK: - Crop Card
struct CropCard: View {
    let crop: Crop
    let onTap: () -> Void
    
    var daysUntilHarvest: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
    }
    
    var formattedPlantingDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: crop.plantingDate)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("field_empty")
                    .resizable()
                    .frame(width: 340, height: 70)
                
                HStack {
                    // Левая сторона - эмодзи и информация
                    HStack(spacing: 12) {
                        Text(Crop.CropType.getEmojiForCrop(crop.name))
                            .font(.system(size: 28))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(crop.name.uppercased())
                                .font(.custom("Chango-Regular", size: 16))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                            
                            Text("PLANTED: \(formattedPlantingDate)")
                                .font(.custom("Chango-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.7))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                    }
                    
                    Spacer()
                    
                    // Правая сторона - статус в обводке
                    ZStack {
                        Image("my_tab")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Text(crop.currentStage.rawValue.uppercased())
                            .font(.custom("Chango-Regular", size: 10))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Crop Type Selection Overlay
struct CropTypeSelectionOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedCropType: Crop.CropType?
    let onCropTypeSelected: () -> Void
    
    // Доступные типы растений
    private let availableCropTypes: [Crop.CropType] = [.vegetables, .fruits, .grains, .herbs, .flowers]
    
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
                            
                            Image("add_crop_text")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 30)
                    
                    Spacer()
                    
                    Image("btn_back")
                        .resizable()
                        .scaledToFit()
                                .frame(width: 40, height: 40)
                        .hidden()
                }
                .padding(.horizontal, 20)
                        
                Spacer()
                        
                // Кнопки типов растений
                VStack(spacing: 12) {
                    ForEach(availableCropTypes, id: \.self) { cropType in
                        Button(action: {
                            selectedCropType = cropType
                            onCropTypeSelected()
                        }) {
                            ZStack {
                                Image("field_empty")
                                    .resizable()
                                    .frame(width: 340, height: 60)
                                
                                HStack {
                                    Text("\(cropType.icon) \(cropType.rawValue.uppercased())")
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

// MARK: - Crop Details Overlay
struct CropDetailsOverlay: View {
    @Binding var isPresented: Bool
    let selectedCropType: Crop.CropType
    let dataManager: FarmDataManager
    
    @State private var selectedCropName: String = ""
    @State private var plantingArea: String = ""
    @State private var plantingDate: Date = Date()
    @State private var expectedHarvestDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var showingCropSelection = false
    
    // Проверка готовности формы
    private var isFormValid: Bool {
        !selectedCropName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !plantingArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                    
                    Image("add_crop_text")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                    
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
                        
                        if showingCropSelection {
                            // Выбор растения
                            CropSelectionView(
                                cropType: selectedCropType,
                                selectedCropName: $selectedCropName,
                                onCropSelected: {
                                    showingCropSelection = false
                                }
                            )
                        } else {
                            // Основная форма
                            VStack(spacing: 16) {
                                // Кнопка выбора растения
                                Button(action: {
                                    showingCropSelection = true
                                }) {
                                    ZStack {
                                        Image("field_empty")
                                            .resizable()
                                            .frame(width: 340, height: 50)
                                        
                                        HStack {
                                            Text(selectedCropName.isEmpty ? "SELECT CROP" : selectedCropName)
                                                .font(.custom("Chango-Regular", size: 14))
                                                .foregroundColor(selectedCropName.isEmpty ? .gray : .white)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 25)
                                        .padding(.vertical, 15)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Поле или участок
                                CropTextField(
                                    placeholder: "PLOT OR FIELD",
                                    text: $plantingArea
                                )
                                
                                // Дата посадки
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("PLANTING DATE")
                                            .font(.custom("Chango-Regular", size: 13))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    CropDatePickerField(selectedDate: $plantingDate)
                                }
                                
                                // Ожидаемая дата сбора урожая
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("EXPECTED HARVEST DATE")
                                            .font(.custom("Chango-Regular", size: 13))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    CropDatePickerField(selectedDate: $expectedHarvestDate)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Отступ перед кнопкой
                            Spacer()
                                .frame(height: 40)
                            
                            // Кнопка NEXT
                            Button(action: {
                                saveCrop()
                            }) {
                                Image("btn_next")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 55)
                                    .opacity(isFormValid ? 1 : 0.5)
                            }
                            .disabled(!isFormValid)
                            .padding(.horizontal, 20)
                        }
                        
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
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Функция сохранения растения
    private func saveCrop() {
        let newCrop = Crop(
            name: selectedCropName,
            variety: selectedCropName, // Пока используем одинаковые названия
            plantingArea: plantingArea.trimmingCharacters(in: .whitespacesAndNewlines),
            plantingDate: plantingDate,
            expectedHarvestDate: expectedHarvestDate,
            currentStage: .planted,
            status: .healthy,
            notes: "",
            harvestAmount: 0,
            unitOfMeasure: "kg",
            cropType: selectedCropType
        )
        
        dataManager.addCrop(newCrop)
        print("✅ Сохранено растение: \(selectedCropName), тип: \(selectedCropType.rawValue)")
        
        isPresented = false
    }
}

// MARK: - Crop Selection View
struct CropSelectionView: View {
    let cropType: Crop.CropType
    @Binding var selectedCropName: String
    let onCropSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(cropType.commonCrops, id: \.self) { cropName in
                Button(action: {
                    selectedCropName = cropName
                    onCropSelected()
                }) {
                    ZStack {
                        Image("field_empty")
                            .resizable()
                            .frame(width: 340, height: 50)
                        
                        HStack {
                            Text("\(Crop.CropType.getEmojiForCrop(cropName)) \(cropName)")
                                .font(.custom("Chango-Regular", size: 14))
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
    }
}

// MARK: - Crop Text Field
struct CropTextField: View {
    let placeholder: String
    @Binding var text: String
    
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
                    .onChange(of: text) { newValue in
                        if newValue.count > 30 {
                            text = String(newValue.prefix(30))
                        }
                    }
                
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
        }
    }
}

// MARK: - Crop Date Picker Field
struct CropDatePickerField: View {
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
                .frame(width: 340)
            
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

// MARK: - Crop Detail Overlay
struct CropDetailOverlay: View {
    @Binding var isPresented: Bool
    let crop: Crop
    let dataManager: FarmDataManager
    let onCropDeleted: (() -> Void)?
    @State private var showingDeleteAlert = false
    
    var daysPlanted: Int {
        Calendar.current.dateComponents([.day], from: crop.plantingDate, to: Date()).day ?? 0
    }
    
    var daysUntilHarvest: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: crop.expectedHarvestDate).day ?? 0
    }
    
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
                    
                    Text("PLANTING CYCLE")
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
                
                // Скроллируемый контент
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Основная карточка с информацией о растении
                        CropMainInfoCard(crop: crop, daysPlanted: daysPlanted, daysUntilHarvest: daysUntilHarvest)
                        
                        // Статусы
                        CropStatusSection(crop: crop)
                        
                        // Нижний отступ
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .alert("Delete Crop?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCrop()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Delete Crop Function
    private func deleteCrop() {
        if let index = dataManager.crops.firstIndex(where: { $0.id == crop.id }) {
            dataManager.crops.remove(at: index)
        }
        
        // Force UI update
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        
        // Call callback to notify parent view
        onCropDeleted?()
        
        // Close overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
        }
    }
}

// MARK: - Crop Main Info Card
struct CropMainInfoCard: View {
    let crop: Crop
    let daysPlanted: Int
    let daysUntilHarvest: Int
    
    var body: some View {
        ZStack {
            Image("rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 320)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            
            VStack(spacing: 12) {
                // Иконка растения
                Text(Crop.CropType.getEmojiForCrop(crop.name))
                    .font(.system(size: 60))
                    .padding(.top, 10)
                
                // Название растения
                Text(crop.name.uppercased())
                    .font(.custom("Chango-Regular", size: 28))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                
                // Участок
                VStack(spacing: 4) {
                    Text("PLANTING AREA")
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(crop.plantingArea.uppercased())
                        .font(.custom("Chango-Regular", size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                
                // Нижний ряд - дни
                HStack(spacing: 60) {
                    // Левая колонка - дни с посадки
                    VStack(spacing: 4) {
                        Text("PLANTED")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(daysPlanted) DAYS")
                            .font(.custom("Chango-Regular", size: 20))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                    
                    // Правая колонка - до сбора урожая
                    VStack(spacing: 4) {
                        Text("HARVEST")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        if daysUntilHarvest > 0 {
                            Text("\(daysUntilHarvest) DAYS")
                                .font(.custom("Chango-Regular", size: 20))
                                .foregroundColor(.orange)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        } else {
                            Text("READY")
                                .font(.custom("Chango-Regular", size: 20))
                                .foregroundColor(.green)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(20)
        }
    }
}

// MARK: - Crop Status Section
struct CropStatusSection: View {
    let crop: Crop
    
    var body: some View {
        VStack(spacing: 15) {
            // Current Status
            CropStatusCard(
                title: "STATUS",
                value: crop.currentStage.rawValue.uppercased(),
                color: getStageColor(crop.currentStage)
            )
            
            // Health Status
            CropStatusCard(
                title: "HEALTH",
                value: crop.status.rawValue.uppercased(),
                color: crop.status.color
            )
        }
    }
    
    private func getStageColor(_ stage: Crop.CropStage) -> Color {
        switch stage {
        case .planted: return .blue
        case .germinating: return .cyan
        case .growing: return .green
        case .flowering: return .purple
        case .fruiting: return .orange
        case .readyToHarvest: return .yellow
        case .harvested: return .gray
        }
    }
}

// MARK: - Crop Status Card
struct CropStatusCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        ZStack {
            Image("field_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 340)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        
                        Text(value)
                            .font(.custom("Chango-Regular", size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
}

#Preview("Planting Cycle - Empty State") {
    PlantingCycleView()
        .environmentObject(FarmDataManager.shared)
}

#Preview("Crop Type Selection") {
    PlantingCycleView()
        .environmentObject(FarmDataManager())
        .overlay(
            CropTypeSelectionOverlay(
                isPresented: .constant(true),
                selectedCropType: .constant(nil),
                onCropTypeSelected: {}
            )
        )
}
