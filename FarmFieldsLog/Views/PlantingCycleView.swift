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
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("plant_cicly_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                    Spacer()
                }
                .padding(.top, 20)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        CropsContentView(
                            dataManager: dataManager,
                            selectedCrop: $selectedCrop
                        )
                        .id("crops_content_\(dataManager.crops.count)")
                        Spacer()
                            .frame(height: 30)
                        Button(action: {
                            showingCropSelection = true
                        }) {
                            Image("btn_add_crop")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 54)
                        }
                        Spacer()
                            .frame(height: 150)
                    }
                }
            }
        }
        .overlay(
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
struct CropsContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedCrop: Crop?
    var hasCrops: Bool {
        !dataManager.crops.isEmpty
    }
    var body: some View {
        VStack(spacing: 0) {
            if hasCrops {
                CropsSection(
                    dataManager: dataManager,
                    selectedCrop: $selectedCrop
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
struct CropsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedCrop: Crop?
    var body: some View {
        VStack(spacing: 8) {
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
            .frame(maxHeight: 300)
        }
        .padding(.horizontal, 12)
    }
}
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
struct CropTypeSelectionOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedCropType: Crop.CropType?
    let onCropTypeSelected: () -> Void
    private let availableCropTypes: [Crop.CropType] = [.vegetables, .fruits, .grains, .herbs, .flowers]
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
struct CropDetailsOverlay: View {
    @Binding var isPresented: Bool
    let selectedCropType: Crop.CropType
    let dataManager: FarmDataManager
    @State private var selectedCropName: String = ""
    @State private var plantingArea: String = ""
    @State private var plantingDate: Date = Date()
    @State private var expectedHarvestDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var showingCropSelection = false
    private var isFormValid: Bool {
        !selectedCropName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !plantingArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        if showingCropSelection {
                            CropSelectionView(
                                cropType: selectedCropType,
                                selectedCropName: $selectedCropName,
                                onCropSelected: {
                                    showingCropSelection = false
                                }
                            )
                        } else {
                            VStack(spacing: 16) {
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
                                CropTextField(
                                    placeholder: "PLOT OR FIELD",
                                    text: $plantingArea
                                )
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
                            Spacer()
                                .frame(height: 40)
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
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveCrop() {
        let newCrop = Crop(
            name: selectedCropName,
            variety: selectedCropName,
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
        isPresented = false
    }
}
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        CropMainInfoCard(crop: crop, daysPlanted: daysPlanted, daysUntilHarvest: daysUntilHarvest)
                        CropStatusSection(crop: crop)
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
    private func deleteCrop() {
        if let index = dataManager.crops.firstIndex(where: { $0.id == crop.id }) {
            dataManager.crops.remove(at: index)
        }
        DispatchQueue.main.async {
            dataManager.objectWillChange.send()
        }
        onCropDeleted?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPresented = false
        }
    }
}
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
                Text(Crop.CropType.getEmojiForCrop(crop.name))
                    .font(.system(size: 60))
                    .padding(.top, 10)
                Text(crop.name.uppercased())
                    .font(.custom("Chango-Regular", size: 28))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                VStack(spacing: 4) {
                    Text("PLANTING AREA")
                        .font(.custom("Chango-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Text(crop.plantingArea.uppercased())
                        .font(.custom("Chango-Regular", size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                }
                HStack(spacing: 60) {
                    VStack(spacing: 4) {
                        Text("PLANTED")
                            .font(.custom("Chango-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(daysPlanted) DAYS")
                            .font(.custom("Chango-Regular", size: 20))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                    }
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
struct CropStatusSection: View {
    let crop: Crop
    var body: some View {
        VStack(spacing: 15) {
            CropStatusCard(
                title: "STATUS",
                value: crop.currentStage.rawValue.uppercased(),
                color: getStageColor(crop.currentStage)
            )
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
