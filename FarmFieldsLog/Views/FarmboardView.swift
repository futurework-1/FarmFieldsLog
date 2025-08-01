import SwiftUI
import UserNotifications
struct FarmboardView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingItemTypeSelection = false
    @State private var showingItemDetails = false
    @State private var selectedItemType: FarmboardItem.FarmboardItemType?
    @State private var selectedItem: FarmboardItem?
    @State private var showingItemDetailView = false
    @State private var cropQuantity: String = ""
    @State private var taskName: String = ""
    @State private var eventName: String = ""
    @State private var animalQuantity: String = ""
    var hasFarmboardItems: Bool {
        !dataManager.farmboardItems.isEmpty
    }
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("farm_text")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Spacer()
                }
                .padding(.top, 20)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 20)
                        FarmboardContentView(
                            dataManager: dataManager,
                            selectedItem: $selectedItem
                        )
                        .id("farmboard_content_\(dataManager.farmboardItems.count)")
                        Spacer()
                            .frame(height: 150)
                        HStack {
                            Button(action: {
                                selectedItemType = .crop
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_crop")
                                    .resizable()
                                    .scaledToFit()
                            }
                            Button(action: {
                                selectedItemType = .animal
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_animal")
                                    .resizable()
                                    .scaledToFit()
                            }
                            Button(action: {
                                selectedItemType = .task
                                showingItemTypeSelection = true
                            }) {
                                Image("btn_task")
                                    .resizable()
                                    .scaledToFit()
                            }
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
                        Spacer()
                            .frame(height: 150)
                    }
                }
            }
        }
        .overlay(
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
                cropQuantity = ""
                taskName = ""
                eventName = ""
                animalQuantity = ""
            }
        }
        .onChange(of: showingItemDetails) { isShowing in
            if !isShowing {
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
struct FarmboardContentView: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedItem: FarmboardItem?
    var hasFarmboardItems: Bool {
        !dataManager.farmboardItems.isEmpty
    }
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
                WeeklyCropSummaryView(
                    totalCropKg: totalCropKg,
                    totalMilkL: totalMilkL,
                    totalEggPcs: totalEggPcs
                )
                if !taskItems.isEmpty {
                    TasksSectionView(
                        tasks: taskItems,
                        selectedItem: $selectedItem
                    )
                }
                if !eventItems.isEmpty {
                    EventsSectionView(
                        events: eventItems,
                        selectedItem: $selectedItem,
                        dataManager: dataManager
                    )
                }
            } else {
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
struct FarmboardItemsSection: View {
    @ObservedObject var dataManager: FarmDataManager
    @Binding var selectedItem: FarmboardItem?
    var body: some View {
        VStack(spacing: 8) {
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
            .frame(maxHeight: 300)
        }
        .padding(.horizontal, 12)
    }
}
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
struct WeeklyCropSummaryView: View {
    let totalCropKg: Int
    let totalMilkL: Int
    let totalEggPcs: Int
    var body: some View {
        VStack(spacing: 12) {
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
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 80)
                    Spacer()
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
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 80)
                    Spacer()
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
struct TasksSectionView: View {
    let tasks: [FarmboardItem]
    @Binding var selectedItem: FarmboardItem?
    var sortedTasks: [FarmboardItem] {
        tasks.sorted { $0.createdDate > $1.createdDate }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("tasks_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Spacer()
            }
            .padding(.horizontal, 20)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(sortedTasks) { task in
                        TaskItemView(task: task) {
                            selectedItem = task
                        }
                    }
                }
            }
            .frame(maxHeight: 140)
        }
    }
}
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
struct EventsSectionView: View {
    let events: [FarmboardItem]
    @Binding var selectedItem: FarmboardItem?
    let dataManager: FarmDataManager
    var sortedEvents: [FarmboardItem] {
        events.sorted { event1, event2 in
            if let date1 = event1.scheduledDate, let date2 = event2.scheduledDate {
                return date1 < date2
            } else if event1.scheduledDate != nil {
                return true
            } else if event2.scheduledDate != nil {
                return false
            } else {
                return event1.createdDate > event2.createdDate
            }
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("event_text")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Spacer()
            }
            .padding(.horizontal, 20)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(sortedEvents) { event in
                        EventItemView(event: event, dataManager: dataManager) {
                            selectedItem = event
                        }
                    }
                }
            }
            .frame(maxHeight: 140)
        }
    }
}
struct EventItemView: View {
    let event: FarmboardItem
    let dataManager: FarmDataManager
    let onTap: () -> Void
    private var timeUntilEvent: String {
        guard let scheduledDate = event.scheduledDate else {
            return "NO DATE"
        }
        let timeInterval = scheduledDate.timeIntervalSince(Date())
        if timeInterval <= 0 {
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
                    Image("my_event")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(timeUntilEvent)
                            .font(.custom("Chango-Regular", size: 10))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
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
            if let scheduledDate = event.scheduledDate, scheduledDate <= Date() {
                dataManager.deleteFarmboardItem(event)
            }
        }
    }
}
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
struct CropTypeSelectionView: View {
    @Binding var cropQuantity: String
    let dataManager: FarmDataManager
    let onCropSaved: () -> Void
    @State private var unit: String = "kg"
    private var isFormValid: Bool {
        !cropQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        cropQuantity.count <= 3 && 
        cropQuantity.allSatisfy { $0.isNumber }
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20)
                Image("crop")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                Spacer()
                    .frame(height: 40)
                ZStack {
                    AnimalTextField(
                        placeholder: "QUANTITY",
                        text: $cropQuantity,
                        keyboardType: .numberPad,
                        isNumericOnly: true
                    )
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
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > 3 {
                        cropQuantity = String(filtered.prefix(3))
                    } else {
                        cropQuantity = filtered
                    }
                }
                Spacer()
                    .frame(height: 30)
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
                Spacer()
                    .frame(height: 200)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveCrop() {
        guard let quantity = Int(cropQuantity) else { return }
        let cropItem = FarmboardItem(
            name: "Crop",
            itemType: .crop,
            quantity: quantity,
            unit: unit,
            notes: ""
        )
        dataManager.addFarmboardItem(cropItem)
        onCropSaved()
    }
}
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
            case .milk: return "l"
            case .egg: return "pcs"
            }
        }
        var name: String {
            switch self {
            case .milk: return "Milk"
            case .egg: return "Egg"
            }
        }
    }
    private var isFormValid: Bool {
        !animalQuantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        animalQuantity.count <= 3 && 
        animalQuantity.allSatisfy { $0.isNumber }
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 40)
                if !showingQuantityInput {
                    Image("my_animal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                    Spacer()
                        .frame(height: 30)
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
                    if let animalType = selectedAnimalType {
                        Image(animalType == .milk ? "milk" : "egg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                        Spacer()
                            .frame(height: 40)
                        ZStack {
                            AnimalTextField(
                                placeholder: "QUANTITY",
                                text: $animalQuantity,
                                keyboardType: .numberPad,
                                isNumericOnly: true
                            )
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
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 3 {
                                animalQuantity = String(filtered.prefix(3))
                            } else {
                                animalQuantity = filtered
                            }
                        }
                        Spacer()
                            .frame(height: 30)
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
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
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
        onAnimalSaved()
    }
}
struct TaskTypeSelectionView: View {
    @Binding var taskName: String
    let dataManager: FarmDataManager
    let onTaskSaved: () -> Void
    private var isFormValid: Bool {
        !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && taskName.count <= 15
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                Image("my_task")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                Spacer()
                    .frame(height: 40)
                AnimalTextField(
                    placeholder: "TASK NAME",
                    text: $taskName,
                    keyboardType: .default
                )
                .onChange(of: taskName) { newValue in
                    if newValue.count > 15 {
                        taskName = String(newValue.prefix(15))
                    }
                }
                Spacer()
                    .frame(height: 30)
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
                Spacer()
                    .frame(height: 200)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveTask() {
        let taskItem = FarmboardItem(
            name: taskName,
            itemType: .task,
            quantity: 1,
            unit: "pcs",
            notes: ""
        )
        dataManager.addFarmboardItem(taskItem)
        onTaskSaved()
    }
}
struct EventTypeSelectionView: View {
    @Binding var eventName: String
    let dataManager: FarmDataManager
    let onEventSaved: () -> Void
    @State private var selectedDate: Date = Date().addingTimeInterval(3600)
    @State private var showingNotificationsDisabledAlert = false
    private var isFormValid: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        eventName.count <= 15 && 
        selectedDate > Date()
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20)
                Image("my_event")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                Spacer()
                    .frame(height: 30)
                AnimalTextField(
                    placeholder: "EVENT NAME",
                    text: $eventName,
                    keyboardType: .default
                )
                .onChange(of: eventName) { newValue in
                    if newValue.count > 15 {
                        eventName = String(newValue.prefix(15))
                    }
                }
                Spacer()
                    .frame(height: 20)
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
                Spacer()
                    .frame(height: 30)
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
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .alert("Notifications Disabled", isPresented: $showingNotificationsDisabledAlert) {
            Button("OK") { }
        } message: {
            Text("To create events with reminders, please enable notifications in the app settings.")
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveEvent() {
        guard dataManager.settings.enableNotifications else {
            showingNotificationsDisabledAlert = true
            return
        }
        requestNotificationPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                    let eventItem = FarmboardItem(
                        name: eventName,
                        itemType: .event,
                        quantity: 1,
                        unit: "pcs",
                        notes: "",
                        scheduledDate: selectedDate
                    )
                    dataManager.addFarmboardItem(eventItem)
                    onEventSaved()
                } else {
                }
            }
        }
    }
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion(granted)
        }
    }
    private func scheduleNotification() {
        guard dataManager.settings.enableNotifications else {
            return
        }
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Farm Reminder"
        content.body = eventName
        content.sound = .default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { error in
        }
    }
}
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        getMainIcon()
                            .padding(.bottom, 30)
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
                        Spacer()
                            .frame(height: 60)
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
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func saveItem() {
        let itemName: String = {
            switch itemType {
            case .crop:
                return "Crop"
            case .task:
                return taskName
            case .event:
                return eventName
            case .animal:
                return "Animal"
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
        isPresented = false
    }
}
struct FarmboardItemDetailOverlay: View {
    @Binding var isPresented: Bool
    let item: FarmboardItem
    let dataManager: FarmDataManager
    let onItemDeleted: () -> Void
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        ZStack {
                            Image("rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320)
                            VStack(spacing: 12) {
                                Image(item.itemType.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 10)
                                Text(item.itemType.rawValue.uppercased())
                                    .font(.custom("Chango-Regular", size: 24))
                                    .foregroundColor(.orange)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                VStack(spacing: 4) {
                                    Text("QUANTITY")
                                        .font(.custom("Chango-Regular", size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("\(item.quantity) \(item.unit)")
                                        .font(.custom("Chango-Regular", size: 28))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                }
                                Text(item.status.rawValue.uppercased())
                                    .font(.custom("Chango-Regular", size: 14))
                                    .foregroundColor(item.status.color)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                    .padding(.bottom, 10)
                            }
                        }
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
#Preview("Farmboard - Empty State") {
    FarmboardView()
        .environmentObject(FarmDataManager())
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
