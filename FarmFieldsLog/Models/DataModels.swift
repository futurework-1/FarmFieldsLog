import Foundation
import SwiftUI
struct FarmTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var dueDate: Date
    var priority: TaskPriority
    var category: TaskCategory
    var createdDate: Date
    init(title: String, description: String, isCompleted: Bool = false, dueDate: Date, priority: TaskPriority, category: TaskCategory, createdDate: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.createdDate = createdDate
    }
    enum TaskPriority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .urgent: return .red
            }
        }
    }
    enum TaskCategory: String, CaseIterable, Codable {
        case watering = "Watering"
        case feeding = "Feeding"
        case harvesting = "Harvesting"
        case cleaning = "Cleaning"
        case maintenance = "Maintenance"
        case veterinary = "Veterinary"
        case planting = "Planting"
        case other = "Other"
        var icon: String {
            switch self {
            case .watering: return "drop.fill"
            case .feeding: return "leaf.fill"
            case .harvesting: return "scissors"
            case .cleaning: return "sparkles"
            case .maintenance: return "wrench.fill"
            case .veterinary: return "heart.fill"
            case .planting: return "seedling"
            case .other: return "circle.fill"
            }
        }
    }
}
struct Crop: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var variety: String
    var plantingArea: String
    var plantingDate: Date
    var expectedHarvestDate: Date
    var currentStage: CropStage
    var status: CropStatus
    var notes: String
    var harvestAmount: Double
    var unitOfMeasure: String
    var cropType: CropType
    init(name: String, variety: String, plantingArea: String, plantingDate: Date, expectedHarvestDate: Date, currentStage: CropStage, status: CropStatus, notes: String, harvestAmount: Double, unitOfMeasure: String, cropType: CropType = .vegetables) {
        self.id = UUID()
        self.name = name
        self.variety = variety
        self.plantingArea = plantingArea
        self.plantingDate = plantingDate
        self.expectedHarvestDate = expectedHarvestDate
        self.currentStage = currentStage
        self.status = status
        self.notes = notes
        self.harvestAmount = harvestAmount
        self.unitOfMeasure = unitOfMeasure
        self.cropType = cropType
    }
    enum CropType: String, CaseIterable, Codable {
        case vegetables = "Vegetables"
        case fruits = "Fruits"
        case grains = "Grains"
        case herbs = "Herbs"
        case flowers = "Flowers"
        var icon: String {
            switch self {
            case .vegetables: return "🥕"
            case .fruits: return "🍎"
            case .grains: return "🌾"
            case .herbs: return "🌿"
            case .flowers: return "🌸"
            }
        }
        var commonCrops: [String] {
            switch self {
            case .vegetables:
                return ["CARROTS", "POTATOES", "TOMATOES", "CUCUMBERS", "PEPPERS", "SPINACH", "CABBAGE", "BROCCOLI"]
            case .fruits:
                return ["STRAWBERRIES", "APPLES", "GRAPES", "BANANAS", "ORANGES", "WATERMELON"]
            case .grains:
                return ["WHEAT", "CORN", "RICE", "BARLEY", "OATS", "RYE"]
            case .herbs:
                return ["BASIL", "PARSLEY", "THYME", "OREGANO", "ROSEMARY", "MINT"]
            case .flowers:
                return ["ROSES", "TULIPS", "SUNFLOWERS", "DAISIES", "LAVENDER", "MARIGOLD"]
            }
        }
        static func getEmojiForCrop(_ cropName: String) -> String {
            switch cropName.uppercased() {
            case "CARROTS": return "🥕"
            case "POTATOES": return "🥔"
            case "TOMATOES": return "🍅"
            case "CUCUMBERS": return "🥒"
            case "PEPPERS": return "🌶️"
            case "SPINACH": return "🥬"
            case "CABBAGE": return "🥬"
            case "BROCCOLI": return "🥦"
            case "CORN": return "🌽"
            case "STRAWBERRIES": return "🍓"
            case "APPLES": return "🍎"
            case "GRAPES": return "🍇"
            case "BANANAS": return "🍌"
            case "ORANGES": return "🍊"
            case "WATERMELON": return "🍉"
            case "WHEAT": return "🌾"
            case "RICE": return "🌾"
            case "BARLEY": return "🌾"
            case "OATS": return "🌾"
            case "RYE": return "🌾"
            case "BASIL": return "🌿"
            case "PARSLEY": return "🌿"
            case "THYME": return "🌿"
            case "OREGANO": return "🌿"
            case "ROSEMARY": return "🌿"
            case "MINT": return "🌿"
            case "ROSES": return "🌹"
            case "TULIPS": return "🌷"
            case "SUNFLOWERS": return "🌻"
            case "DAISIES": return "🌼"
            case "LAVENDER": return "💜"
            case "MARIGOLD": return "🌻"
            default: return "🌱"
            }
        }
    }
    enum CropStage: String, CaseIterable, Codable {
        case planted = "Planted"
        case germinating = "Germinating"
        case growing = "Growing"
        case flowering = "Flowering"
        case fruiting = "Fruiting"
        case readyToHarvest = "Ready to Harvest"
        case harvested = "Harvested"
    }
    enum CropStatus: String, CaseIterable, Codable {
        case healthy = "Healthy"
        case needsAttention = "Needs Attention"
        case diseased = "Diseased"
        case pest = "Pest Problem"
        case drought = "Drought Stress"
        var color: Color {
            switch self {
            case .healthy: return .green
            case .needsAttention: return .yellow
            case .diseased: return .red
            case .pest: return .orange
            case .drought: return .brown
            }
        }
    }
}
struct Animal: Identifiable, Codable, Equatable {
    let id: UUID
    var species: AnimalSpecies
    var breed: String
    var name: String?
    var count: Int
    var age: String
    var healthStatus: HealthStatus
    var lastVaccination: Date?
    var nextVaccination: Date?
    var notes: String
    var isHighProducer: Bool
    init(species: AnimalSpecies, breed: String, name: String? = nil, count: Int, age: String, healthStatus: HealthStatus, lastVaccination: Date? = nil, nextVaccination: Date? = nil, notes: String, isHighProducer: Bool = false) {
        self.id = UUID()
        self.species = species
        self.breed = breed
        self.name = name
        self.count = count
        self.age = age
        self.healthStatus = healthStatus
        self.lastVaccination = lastVaccination
        self.nextVaccination = nextVaccination
        self.notes = notes
        self.isHighProducer = isHighProducer
    }
    enum AnimalSpecies: String, CaseIterable, Codable {
        case chicken = "Chicken"
        case cow = "Cow"
        case pig = "Pig"
        case sheep = "Sheep"
        case goat = "Goat"
        case duck = "Duck"
        case turkey = "Turkey"
        case rabbit = "Rabbit"
        var icon: String {
            switch self {
            case .chicken: return "🐔"
            case .cow: return "🐄"
            case .pig: return "🐷"
            case .sheep: return "🐑"
            case .goat: return "🐐"
            case .duck: return "🦆"
            case .turkey: return "🦃"
            case .rabbit: return "🐰"
            }
        }
    }
    enum HealthStatus: String, CaseIterable, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
        case sick = "Sick"
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .mint
            case .fair: return .yellow
            case .poor: return .orange
            case .sick: return .red
            }
        }
    }
}
struct ProductionRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var productType: ProductType
    var amount: Double
    var unit: String
    var animalId: UUID?
    var notes: String
    init(date: Date, productType: ProductType, amount: Double, unit: String, animalId: UUID? = nil, notes: String) {
        self.id = UUID()
        self.date = date
        self.productType = productType
        self.amount = amount
        self.unit = unit
        self.animalId = animalId
        self.notes = notes
    }
    enum ProductType: String, CaseIterable, Codable {
        case eggs = "Eggs"
        case milk = "Milk"
        case meat = "Meat"
        case wool = "Wool"
        case honey = "Honey"
        var icon: String {
            switch self {
            case .eggs: return "circle.fill"
            case .milk: return "drop.fill"
            case .meat: return "flame.fill"
            case .wool: return "circle.dotted"
            case .honey: return "hexagon.fill"
            }
        }
        var color: Color {
            switch self {
            case .eggs: return .yellow
            case .milk: return .white
            case .meat: return .red
            case .wool: return .gray
            case .honey: return .orange
            }
        }
    }
}
struct StorageItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: StorageCategory
    var currentStock: Double
    var minimumStock: Double
    var unit: String
    var expirationDate: Date?
    var lastUpdated: Date
    var cost: Double
    var supplier: String
    init(name: String, category: StorageCategory, currentStock: Double, minimumStock: Double, unit: String, expirationDate: Date? = nil, lastUpdated: Date = Date(), cost: Double = 0, supplier: String = "") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.currentStock = currentStock
        self.minimumStock = minimumStock
        self.unit = unit
        self.expirationDate = expirationDate
        self.lastUpdated = lastUpdated
        self.cost = cost
        self.supplier = supplier
    }
    var isLowStock: Bool {
        return currentStock <= minimumStock
    }
    enum StorageCategory: String, CaseIterable, Codable {
        case feed = "Feed"
        case fertilizer = "Fertilizer"
        case seeds = "Seeds"
        case medicine = "Medicine"
        case tools = "Tools"
        case supplies = "Supplies"
        var icon: String {
            switch self {
            case .feed: return "leaf.fill"
            case .fertilizer: return "flask.fill"
            case .seeds: return "seedling"
            case .medicine: return "cross.fill"
            case .tools: return "wrench.fill"
            case .supplies: return "box.fill"
            }
        }
        var color: Color {
            switch self {
            case .feed: return .green
            case .fertilizer: return .brown
            case .seeds: return .orange
            case .medicine: return .red
            case .tools: return .blue
            case .supplies: return .purple
            }
        }
    }
}
struct FarmEvent: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var eventType: EventType
    var isCompleted: Bool
    var reminderDate: Date?
    var relatedAnimalId: UUID?
    var relatedCropId: UUID?
    init(title: String, description: String, date: Date, eventType: EventType, isCompleted: Bool = false, reminderDate: Date? = nil, relatedAnimalId: UUID? = nil, relatedCropId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.date = date
        self.eventType = eventType
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.relatedAnimalId = relatedAnimalId
        self.relatedCropId = relatedCropId
    }
    enum EventType: String, CaseIterable, Codable {
        case veterinaryVisit = "Veterinary Visit"
        case vaccination = "Vaccination"
        case harvest = "Harvest"
        case planting = "Planting"
        case maintenance = "Maintenance"
        case inspection = "Inspection"
        case treatment = "Treatment"
        case other = "Other"
        var icon: String {
            switch self {
            case .veterinaryVisit: return "stethoscope"
            case .vaccination: return "syringe"
            case .harvest: return "scissors"
            case .planting: return "seedling"
            case .maintenance: return "wrench.fill"
            case .inspection: return "magnifyingglass"
            case .treatment: return "cross.fill"
            case .other: return "calendar"
            }
        }
        var color: Color {
            switch self {
            case .veterinaryVisit: return .blue
            case .vaccination: return .green
            case .harvest: return .orange
            case .planting: return .mint
            case .maintenance: return .gray
            case .inspection: return .purple
            case .treatment: return .red
            case .other: return .secondary
            }
        }
    }
}
struct WeightChangeRecord: Identifiable, Codable {
    let id: UUID
    var animalId: UUID
    var date: Date
    var weightChange: Double
    var unit: String
    var notes: String
    init(animalId: UUID, date: Date, weightChange: Double, unit: String, notes: String = "") {
        self.id = UUID()
        self.animalId = animalId
        self.date = date
        self.weightChange = weightChange
        self.unit = unit
        self.notes = notes
    }
    var isPositiveChange: Bool {
        return weightChange > 0
    }
    var formattedChange: String {
        let sign = weightChange > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", weightChange)) \(unit)"
    }
}
struct AppSettings: Codable, Equatable {
    var weightUnit: WeightUnit = .kilograms
    var volumeUnit: VolumeUnit = .liters
    var areaUnit: AreaUnit = .squareMeters
    var selectedPrimaryUnit: PrimaryUnit = .kilograms
    var enableNotifications: Bool = false
    var enableTaskReminders: Bool = true
    var enableWateringReminders: Bool = true
    var enableVaccinationReminders: Bool = true
    var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    enum PrimaryUnit: String, CaseIterable, Codable, Equatable {
        case kilograms = "KILOGRAMS (KG)"
        case liters = "LITERS (L)"
        case pieces = "PIECES (PCS)"
        var shortName: String {
            switch self {
            case .kilograms: return "kg"
            case .liters: return "L"
            case .pieces: return "pcs"
            }
        }
    }
    enum WeightUnit: String, CaseIterable, Codable, Equatable {
        case kilograms = "kg"
        case pounds = "lbs"
        case grams = "g"
    }
    enum VolumeUnit: String, CaseIterable, Codable, Equatable {
        case liters = "L"
        case gallons = "gal"
        case milliliters = "mL"
    }
    enum AreaUnit: String, CaseIterable, Codable, Equatable {
        case squareMeters = "m²"
        case squareFeet = "ft²"
        case acres = "acres"
        case hectares = "ha"
    }
}
struct FarmboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var itemType: FarmboardItemType
    var quantity: Int
    var unit: String
    var createdDate: Date
    var status: FarmboardItemStatus
    var notes: String
    var scheduledDate: Date?
    init(name: String, itemType: FarmboardItemType, quantity: Int, unit: String, status: FarmboardItemStatus = .active, notes: String = "", scheduledDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.itemType = itemType
        self.quantity = quantity
        self.unit = unit
        self.createdDate = Date()
        self.status = status
        self.notes = notes
        self.scheduledDate = scheduledDate
    }
    enum FarmboardItemType: String, CaseIterable, Codable {
        case crop = "Crop"
        case animal = "Animal"
        case task = "Task"
        case event = "Event"
        var imageName: String {
            switch self {
            case .crop: return "my_crop"
            case .animal: return "btn_animal"
            case .task: return "my_task"
            case .event: return "my_event"
            }
        }
        var buttonImageName: String {
            switch self {
            case .crop: return "btn_crop"
            case .animal: return "btn_animal"
            case .task: return "btn_task"
            case .event: return "btn_event"
            }
        }
        var color: Color {
            switch self {
            case .crop: return .green
            case .animal: return .orange
            case .task: return .blue
            case .event: return .purple
            }
        }
    }
    enum FarmboardItemStatus: String, CaseIterable, Codable {
        case active = "Active"
        case completed = "Completed"
        case pending = "Pending"
        case archived = "Archived"
        var color: Color {
            switch self {
            case .active: return .green
            case .completed: return .blue
            case .pending: return .orange
            case .archived: return .gray
            }
        }
    }
}