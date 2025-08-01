import SwiftUI

struct FarmboardView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingItemTypeSelection = false
    @State private var showingItemDetails = false
    @State private var selectedItemType: FarmboardItem.FarmboardItemType?
    @State private var selectedItem: FarmboardItem?
    @State private var showingItemDetailView = false
    
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
                        .frame(height: 32)
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
            Group {
                if showingItemTypeSelection {
                    FarmboardItemTypeOverlay(
                        isPresented: $showingItemTypeSelection,
                        selectedItemType: selectedItemType ?? .crop,
                        onItemTypeConfirmed: {
                            showingItemTypeSelection = false
                            showingItemDetails = true
                        }
                    )
                } else if showingItemDetails {
                    FarmboardItemDetailsOverlay(
                        isPresented: $showingItemDetails,
                        itemType: selectedItemType ?? .crop,
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
        .onChange(of: showingItemDetails) { isShowing in
            if !isShowing {
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
    
    var body: some View {
        VStack(spacing: 0) {
            if hasFarmboardItems {
                // Список элементов farmboard
                FarmboardItemsSection(
                    dataManager: dataManager,
                    selectedItem: $selectedItem
                )
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
                        
                        Text("\(item.name) - QTY: \(item.quantity) \(item.unit)")
                            .font(.custom("Chango-Regular", size: 12))
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

// MARK: - Overlay Components

// Overlay для выбора типа элемента (заглушка)
struct FarmboardItemTypeOverlay: View {
    @Binding var isPresented: Bool
    let selectedItemType: FarmboardItem.FarmboardItemType
    let onItemTypeConfirmed: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Add \(selectedItemType.rawValue)")
                    .font(.custom("Chango-Regular", size: 24))
                    .foregroundColor(.white)
                
                Button("Continue") {
                    onItemTypeConfirmed()
                }
                .font(.custom("Chango-Regular", size: 18))
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.yellow)
                .cornerRadius(8)
                
                Button("Cancel") {
                    isPresented = false
                }
                .font(.custom("Chango-Regular", size: 16))
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
}

// Overlay для ввода деталей элемента (заглушка)
struct FarmboardItemDetailsOverlay: View {
    @Binding var isPresented: Bool
    let itemType: FarmboardItem.FarmboardItemType
    let dataManager: FarmDataManager
    
    @State private var name: String = ""
    @State private var quantity: String = "1"
    @State private var unit: String = "pcs"
    @State private var notes: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Add \(itemType.rawValue)")
                    .font(.custom("Chango-Regular", size: 24))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        TextField("Unit", text: $unit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(spacing: 20) {
                    Button("Save") {
                        let item = FarmboardItem(
                            name: name.isEmpty ? itemType.rawValue : name,
                            itemType: itemType,
                            quantity: Int(quantity) ?? 1,
                            unit: unit,
                            notes: notes
                        )
                        dataManager.addFarmboardItem(item)
                        isPresented = false
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
                    .disabled(name.isEmpty)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.9))
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
}

// Overlay для просмотра деталей элемента (заглушка)
struct FarmboardItemDetailOverlay: View {
    @Binding var isPresented: Bool
    let item: FarmboardItem
    let dataManager: FarmDataManager
    let onItemDeleted: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text(item.name)
                    .font(.custom("Chango-Regular", size: 24))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type: \(item.itemType.rawValue)")
                        .foregroundColor(.white)
                    Text("Quantity: \(item.quantity) \(item.unit)")
                        .foregroundColor(.white)
                    Text("Status: \(item.status.rawValue)")
                        .foregroundColor(.white)
                    if !item.notes.isEmpty {
                        Text("Notes: \(item.notes)")
                            .foregroundColor(.white)
                    }
                }
                
                HStack(spacing: 20) {
                    Button("Delete") {
                        dataManager.deleteFarmboardItem(item)
                        onItemDeleted()
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(8)
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .font(.custom("Chango-Regular", size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.yellow)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.9))
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    FarmboardView()
        .environmentObject(FarmDataManager.shared)
}
