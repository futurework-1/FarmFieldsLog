import SwiftUI

struct FarmboardView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var showingAddTask = false
    @State private var showingAddCrop = false
    @State private var showingAddAnimal = false
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Good Morning, Farmer!")
                                .font(.custom("Chango-Regular", size: 24))
                                .foregroundColor(.primary)
                            
                            Text("Here's your farm overview")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "sun.max.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    
                    // Productivity Overview Cards
                    ProductivityOverviewSection()
                    
                    // Today's Tasks
                    TodayTasksSection(showingAddTask: $showingAddTask)
                    
                    // Upcoming Reminders
                    UpcomingRemindersSection()
                    
                    // Quick Actions
                    QuickActionsSection(
                        showingAddCrop: $showingAddCrop,
                        showingAddAnimal: $showingAddAnimal,
                        showingAddTask: $showingAddTask,
                        showingAddEvent: $showingAddEvent
                    )
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Farmboard")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddCrop) {
            AddCropView()
        }
        .sheet(isPresented: $showingAddAnimal) {
            AddAnimalView()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
    }
}

// MARK: - Productivity Overview Section
struct ProductivityOverviewSection: View {
    @EnvironmentObject var dataManager: FarmDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Weekly Overview")
                    .font(.custom("Chango-Regular", size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Harvest Card
                    ProductivityCard(
                        icon: "scissors",
                        title: "Harvest",
                        value: "\(Int(dataManager.getWeeklyHarvest())) kg",
                        subtitle: "This Week",
                        color: .green
                    )
                    
                    // Eggs Card
                    ProductivityCard(
                        icon: "circle.fill",
                        title: "Eggs Collected",
                        value: "\(dataManager.getWeeklyEggs())",
                        subtitle: "This Week",
                        color: .yellow
                    )
                    
                    // Milk Card
                    ProductivityCard(
                        icon: "drop.fill",
                        title: "Milk Production",
                        value: "\(String(format: "%.1f", dataManager.getWeeklyMilk())) L",
                        subtitle: "This Week",
                        color: .blue
                    )
                    
                    // Animals Card
                    ProductivityCard(
                        icon: "pawprint.fill",
                        title: "Animals",
                        value: "\(dataManager.animals.reduce(0) { $0 + $1.count })",
                        subtitle: "Total Count",
                        color: .orange
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Today's Tasks Section
struct TodayTasksSection: View {
    @EnvironmentObject var dataManager: FarmDataManager
    @Binding var showingAddTask: Bool
    
    var todayTasks: [FarmTask] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        return dataManager.tasks.filter { task in
            !task.isCompleted && task.dueDate >= today && task.dueDate < tomorrow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today's Tasks")
                    .font(.custom("Chango-Regular", size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Add Task") {
                    showingAddTask = true
                }
                .font(.caption)
                .foregroundColor(.green)
            }
            .padding(.horizontal)
            
            if todayTasks.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("No tasks for today!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Great job! Your farm is up to date.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(todayTasks) { task in
                        TaskRowView(task: task)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Upcoming Reminders Section
struct UpcomingRemindersSection: View {
    @EnvironmentObject var dataManager: FarmDataManager
    
    var upcomingEvents: [FarmEvent] {
        dataManager.getUpcomingEvents().prefix(3).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Upcoming Reminders")
                    .font(.custom("Chango-Regular", size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            
            if upcomingEvents.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("No upcoming events")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(upcomingEvents, id: \.id) { event in
                        EventRowView(event: event)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    @Binding var showingAddCrop: Bool
    @Binding var showingAddAnimal: Bool
    @Binding var showingAddTask: Bool
    @Binding var showingAddEvent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Quick Actions")
                    .font(.custom("Chango-Regular", size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                QuickActionButton(
                    icon: "scissors",
                    title: "Add Harvest",
                    color: .green
                ) {
                    showingAddCrop = true
                }
                
                QuickActionButton(
                    icon: "pawprint.fill",
                    title: "Add Animal",
                    color: .orange
                ) {
                    showingAddAnimal = true
                }
                
                QuickActionButton(
                    icon: "checkmark.circle",
                    title: "Create Task",
                    color: .blue
                ) {
                    showingAddTask = true
                }
                
                QuickActionButton(
                    icon: "calendar.badge.plus",
                    title: "Add Event",
                    color: .purple
                ) {
                    showingAddEvent = true
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Views
struct ProductivityCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.custom("Chango-Regular", size: 20))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140, height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct TaskRowView: View {
    @EnvironmentObject var dataManager: FarmDataManager
    let task: FarmTask
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                dataManager.toggleTaskCompletion(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack {
                    Image(systemName: task.category.icon)
                        .font(.caption)
                        .foregroundColor(task.priority.color)
                    
                    Text(task.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(task.priority.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(task.priority.color.opacity(0.2))
                        .foregroundColor(task.priority.color)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct EventRowView: View {
    let event: FarmEvent
    
    var daysUntil: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: event.date).day ?? 0
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "In \(days) days"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.eventType.icon)
                .font(.title3)
                .foregroundColor(event.eventType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(event.eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(daysUntil)
                .font(.caption)
                .foregroundColor(.blue)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FarmboardView()
        .environmentObject(FarmDataManager.shared)
}