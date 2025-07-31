import Foundation
import SwiftUI

// MARK: - Task Model
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

// MARK: - Crop Model
struct Crop: Identifiable, Codable {
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
    
    init(name: String, variety: String, plantingArea: String, plantingDate: Date, expectedHarvestDate: Date, currentStage: CropStage, status: CropStatus, notes: String, harvestAmount: Double, unitOfMeasure: String) {
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

// MARK: - Animal Model
struct Animal: Identifiable, Codable {
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

// MARK: - Production Record Model
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

// MARK: - Storage Item Model
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

// MARK: - Event Model
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

// MARK: - App Settings Model
struct AppSettings: Codable, Equatable {
    var weightUnit: WeightUnit = .kilograms
    var volumeUnit: VolumeUnit = .liters
    var areaUnit: AreaUnit = .squareMeters
    var selectedPrimaryUnit: PrimaryUnit = .kilograms // Основная выбранная единица измерения
    var enableNotifications: Bool = true
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