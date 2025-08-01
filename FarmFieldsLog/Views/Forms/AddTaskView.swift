import SwiftUI
struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: FarmDataManager
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority = FarmTask.TaskPriority.medium
    @State private var category = FarmTask.TaskCategory.other
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Classification")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(FarmTask.TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(FarmTask.TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    private func saveTask() {
        let newTask = FarmTask(
            title: title,
            description: description,
            isCompleted: false,
            dueDate: dueDate,
            priority: priority,
            category: category,
            createdDate: Date()
        )
        dataManager.addTask(newTask)
        dismiss()
    }
}
#Preview {
    AddTaskView()
        .environmentObject(FarmDataManager.shared)
}