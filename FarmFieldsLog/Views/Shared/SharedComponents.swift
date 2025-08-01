import SwiftUI
struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            VStack(spacing: 8) {
                Text(title)
                    .font(.custom("Chango-Regular", size: 20))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Button(action: action) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
struct LoadingView: View {
    let message: String
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.5)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            if let retryAction = retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}
struct SectionHeaderView: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    init(title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Chango-Regular", size: 18))
                    .foregroundColor(.primary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let action = action, let actionTitle = actionTitle {
                Button(actionTitle) {
                    action()
                }
                .font(.caption)
                .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
    }
}
struct CardContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}
struct PriorityBadge: View {
    let priority: FarmTask.TaskPriority
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color.opacity(0.2))
            .foregroundColor(priority.color)
            .cornerRadius(4)
    }
}
struct StatusCircle: View {
    let color: Color
    let size: CGFloat
    init(color: Color, size: CGFloat = 12) {
        self.color = color
        self.size = size
    }
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    init(progress: Double, color: Color = .green, lineWidth: CGFloat = 4, size: CGFloat = 40) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?
    init(title: String, value: String, icon: String, color: Color, trend: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
                if let trend = trend {
                    Text(trend)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Text(value)
                .font(.custom("Chango-Regular", size: 20))
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
extension Font {
    static func changoRegular(size: CGFloat) -> Font {
        return .custom("Chango-Regular", size: size)
    }
}
extension Date {
    func daysFromNow() -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    func isTomorrow() -> Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    func formattedRelativeString() -> String {
        let days = daysFromNow()
        if isToday() {
            return "Today"
        } else if isTomorrow() {
            return "Tomorrow"
        } else if days > 0 {
            return "In \(days) day\(days == 1 ? "" : "s")"
        } else {
            return "\(-days) day\(days == -1 ? "" : "s") ago"
        }
    }
}
extension Color {
    static let farmGreen = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let farmBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let farmOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let farmBrown = Color(red: 0.6, green: 0.4, blue: 0.2)
}
#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""))
        HStack {
            FilterChip(title: "All", isSelected: true) { }
            FilterChip(title: "Active", isSelected: false) { }
        }
        MetricCard(
            title: "Total Harvest",
            value: "124 kg",
            icon: "scissors",
            color: .green,
            trend: "+12%"
        )
        ProgressRing(progress: 0.7)
    }
    .padding()
}