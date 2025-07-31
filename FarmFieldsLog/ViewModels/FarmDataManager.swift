import Foundation
import SwiftUI

class FarmDataManager: ObservableObject {
    static let shared = FarmDataManager()
    
    @Published var tasks: [FarmTask] = []
    @Published var crops: [Crop] = []
    @Published var animals: [Animal] = []
    @Published var productionRecords: [ProductionRecord] = []
    @Published var storageItems: [StorageItem] = []
    @Published var events: [FarmEvent] = []
    @Published var settings: AppSettings = AppSettings()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadData()
        createSampleData()
    }
    
    // MARK: - Data Persistence
    func saveData() {
        saveToUserDefaults(tasks, key: "farm_tasks")
        saveToUserDefaults(crops, key: "farm_crops")
        saveToUserDefaults(animals, key: "farm_animals")
        saveToUserDefaults(productionRecords, key: "production_records")
        saveToUserDefaults(storageItems, key: "storage_items")
        saveToUserDefaults(events, key: "farm_events")
        saveToUserDefaults(settings, key: "app_settings")
    }
    
    private func loadData() {
        tasks = loadFromUserDefaults([FarmTask].self, key: "farm_tasks") ?? []
        crops = loadFromUserDefaults([Crop].self, key: "farm_crops") ?? []
        animals = loadFromUserDefaults([Animal].self, key: "farm_animals") ?? []
        productionRecords = loadFromUserDefaults([ProductionRecord].self, key: "production_records") ?? []
        storageItems = loadFromUserDefaults([StorageItem].self, key: "storage_items") ?? []
        events = loadFromUserDefaults([FarmEvent].self, key: "farm_events") ?? []
        settings = loadFromUserDefaults(AppSettings.self, key: "app_settings") ?? AppSettings()
    }
    
    private func saveToUserDefaults<T: Codable>(_ object: T, key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    private func loadFromUserDefaults<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Tasks Management
    func addTask(_ task: FarmTask) {
        tasks.append(task)
        saveData()
    }
    
    func updateTask(_ task: FarmTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
        saveData()
    }
    
    func toggleTaskCompletion(_ task: FarmTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveData()
        }
    }
    
    // MARK: - Crops Management
    func addCrop(_ crop: Crop) {
        crops.append(crop)
        saveData()
    }
    
    func updateCrop(_ crop: Crop) {
        if let index = crops.firstIndex(where: { $0.id == crop.id }) {
            crops[index] = crop
            saveData()
        }
    }
    
    func deleteCrop(at indexSet: IndexSet) {
        crops.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Animals Management
    func addAnimal(_ animal: Animal) {
        animals.append(animal)
        saveData()
    }
    
    func updateAnimal(_ animal: Animal) {
        if let index = animals.firstIndex(where: { $0.id == animal.id }) {
            animals[index] = animal
            saveData()
        }
    }
    
    func deleteAnimal(at indexSet: IndexSet) {
        animals.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Production Records Management
    func addProductionRecord(_ record: ProductionRecord) {
        productionRecords.append(record)
        saveData()
    }
    
    func updateProductionRecord(_ record: ProductionRecord) {
        if let index = productionRecords.firstIndex(where: { $0.id == record.id }) {
            productionRecords[index] = record
            saveData()
        }
    }
    
    func deleteProductionRecord(at indexSet: IndexSet) {
        productionRecords.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Storage Management
    func addStorageItem(_ item: StorageItem) {
        storageItems.append(item)
        saveData()
    }
    
    func updateStorageItem(_ item: StorageItem) {
        if let index = storageItems.firstIndex(where: { $0.id == item.id }) {
            storageItems[index] = item
            saveData()
        }
    }
    
    func deleteStorageItem(at indexSet: IndexSet) {
        storageItems.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Events Management
    func addEvent(_ event: FarmEvent) {
        events.append(event)
        saveData()
    }
    
    func updateEvent(_ event: FarmEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveData()
        }
    }
    
    func deleteEvent(at indexSet: IndexSet) {
        events.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Analytics & Statistics
    func getWeeklyHarvest() -> Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyRecords = productionRecords.filter { $0.date >= weekAgo }
        return weeklyRecords.reduce(0) { total, record in
            if record.productType == .eggs || record.productType == .milk {
                return total + record.amount
            }
            return total
        }
    }
    
    func getWeeklyEggs() -> Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let eggRecords = productionRecords.filter { 
            $0.date >= weekAgo && $0.productType == .eggs 
        }
        return Int(eggRecords.reduce(0) { $0 + $1.amount })
    }
    
    func getWeeklyMilk() -> Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let milkRecords = productionRecords.filter { 
            $0.date >= weekAgo && $0.productType == .milk 
        }
        return milkRecords.reduce(0) { $0 + $1.amount }
    }
    
    func getPendingTasks() -> [FarmTask] {
        return tasks.filter { !$0.isCompleted }
    }
    
    func getUpcomingEvents() -> [FarmEvent] {
        let today = Date()
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
        return events.filter { 
            $0.date >= today && $0.date <= nextWeek && !$0.isCompleted 
        }.sorted { $0.date < $1.date }
    }
    
    func getLowStockItems() -> [StorageItem] {
        return storageItems.filter { $0.isLowStock }
    }
    
    // MARK: - Sample Data Creation
    private func createSampleData() {
        if tasks.isEmpty {
            let sampleTasks = [
                FarmTask(
                    title: "Water Tomatoes",
                    description: "Check and water tomato plants in greenhouse",
                    isCompleted: false,
                    dueDate: Date(),
                    priority: .medium,
                    category: .watering,
                    createdDate: Date()
                ),
                FarmTask(
                    title: "Feed Chickens",
                    description: "Morning feeding for laying hens",
                    isCompleted: false,
                    dueDate: Date(),
                    priority: .high,
                    category: .feeding,
                    createdDate: Date()
                ),
                FarmTask(
                    title: "Clean Pig Pen",
                    description: "Weekly cleaning of pig enclosure",
                    isCompleted: false,
                    dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    priority: .medium,
                    category: .cleaning,
                    createdDate: Date()
                )
            ]
            tasks = sampleTasks
        }
        
        if animals.isEmpty {
            let sampleAnimals = [
                Animal(
                    species: .chicken,
                    breed: "Rhode Island Red",
                    name: nil,
                    count: 15,
                    age: "1 year",
                    healthStatus: .excellent,
                    lastVaccination: Calendar.current.date(byAdding: .month, value: -3, to: Date()),
                    nextVaccination: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                    notes: "High egg production",
                    isHighProducer: true
                ),
                Animal(
                    species: .cow,
                    breed: "Holstein",
                    name: "Bessie",
                    count: 1,
                    age: "3 years",
                    healthStatus: .good,
                    lastVaccination: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
                    nextVaccination: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                    notes: "Good milk producer",
                    isHighProducer: true
                )
            ]
            animals = sampleAnimals
        }
        
        if productionRecords.isEmpty {
            let sampleRecords = [
                ProductionRecord(
                    date: Date(),
                    productType: .eggs,
                    amount: 12,
                    unit: "pieces",
                    animalId: animals.first?.id,
                    notes: "Morning collection"
                ),
                ProductionRecord(
                    date: Date(),
                    productType: .milk,
                    amount: 15.5,
                    unit: "liters",
                    animalId: animals.last?.id,
                    notes: "Evening milking"
                )
            ]
            productionRecords = sampleRecords
        }
        
        saveData()
    }
    
    // MARK: - Settings Management
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveData()
    }
    
    func clearAllData() {
        tasks.removeAll()
        crops.removeAll()
        animals.removeAll()
        productionRecords.removeAll()
        storageItems.removeAll()
        events.removeAll()
        saveData()
    }
}