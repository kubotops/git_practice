import SwiftUI
import Charts

@main
struct HabitShieldApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Temptation: Codable, Identifiable {
    let id: UUID
    var timestamp: Date
    let trigger: String

    init(id: UUID = UUID(), timestamp: Date = Date(), trigger: String) {
        self.id = id
        self.timestamp = timestamp
        self.trigger = trigger
    }
}

struct ContentView: View {
    @AppStorage("weeklyGoal") private var weeklyGoal = 7
    @AppStorage("temptations") private var temptationsData = Data()
    @State private var showingLogSheet = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                UrgesTab(temptationsData: $temptationsData, weeklyGoal: weeklyGoal, showingLogSheet: $showingLogSheet)
                    .tag(0)
                    .tabItem {
                        Label("Urges", systemImage: "list.bullet")
                    }

                ProgressTab(temptationsData: $temptationsData, weeklyGoal: $weeklyGoal)
                    .tag(1)
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
            }
            .tint(.white)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingLogSheet = true
                    } label: {
                        Image(systemName: "waveform")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(20)
                            .glassEffect(in: .circle)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showingLogSheet) {
            LogTemptationView(temptationsData: $temptationsData)
        }
    }
}

struct UrgesTab: View {
    @Binding var temptationsData: Data
    let weeklyGoal: Int
    @Binding var showingLogSheet: Bool

    private var temptations: [Temptation] {
        (try? JSONDecoder().decode([Temptation].self, from: temptationsData)) ?? []
    }

    private var thisWeekTemptations: [Temptation] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date else {
            return []
        }
        return temptations.filter { $0.timestamp >= weekStart }
    }

    private var daysRemainingInWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday == 1) ? 6 : (weekday - 2)
        return 6 - daysFromMonday
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)

                    VStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("\(thisWeekTemptations.count)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                            Text("/")
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                            Text("\(weeklyGoal)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .foregroundStyle(.white)

                        Text("fell this week")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))

                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.callout)
                            Text("\(daysRemainingInWeek) \(daysRemainingInWeek == 1 ? "day" : "days") left in week")
                                .font(.callout)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .glassEffect(in: .rect(cornerRadius: 32))
                    .padding(.horizontal)

                    if thisWeekTemptations.count < weeklyGoal {
                        Text("Think twice — is this moment really worth it?")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text("You've reached your weekly goal. Stay strong!")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if !thisWeekTemptations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Week")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                ForEach(thisWeekTemptations.sorted(by: { $0.timestamp > $1.timestamp })) { temptation in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(temptation.trigger)
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Text(temptation.timestamp, style: .date)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.7))
                                            + Text(" • ")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.7))
                                            + Text(temptation.timestamp, style: .time)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .glassEffect(in: .rect(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .frame(maxWidth: .infinity)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0, green: 0.8, blue: 0.9), Color(red: 0, green: 0.2, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Urges")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct ProgressTab: View {
    @Binding var temptationsData: Data
    @Binding var weeklyGoal: Int
    @State private var showingSettings = false

    private var temptations: [Temptation] {
        (try? JSONDecoder().decode([Temptation].self, from: temptationsData)) ?? []
    }

    private var weeklyData: [(weekStart: Date, count: Int, goal: Int)] {
        let calendar = Calendar.current
        var weekCounts: [Date: Int] = [:]

        for temptation in temptations {
            if let weekStart = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: temptation.timestamp).date {
                weekCounts[weekStart, default: 0] += 1
            }
        }

        let sortedWeeks = weekCounts.keys.sorted()

        if sortedWeeks.isEmpty {
            let now = Date()
            if let currentWeekStart = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date {
                return [(currentWeekStart, 0, weeklyGoal)]
            }
            return []
        }

        guard let firstWeek = sortedWeeks.first,
              let lastWeek = sortedWeeks.last else {
            return []
        }

        var result: [(Date, Int, Int)] = []
        var currentWeek = firstWeek

        while currentWeek <= lastWeek {
            let count = weekCounts[currentWeek] ?? 0
            result.append((currentWeek, count, weeklyGoal))

            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) else {
                break
            }
            currentWeek = nextWeek
        }

        return result
    }

    private var thisWeekTemptations: [Temptation] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date else {
            return []
        }
        return temptations.filter { $0.timestamp >= weekStart }
    }

    private var triggerCounts: [(String, Int)] {
        let counts = Dictionary(grouping: thisWeekTemptations, by: { $0.trigger })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return counts
    }

    private var timeOfDayCounts: [(String, Int)] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: thisWeekTemptations) { temptation -> String in
            let hour = calendar.component(.hour, from: temptation.timestamp)
            switch hour {
            case 0..<6: return "Night (12am-6am)"
            case 6..<12: return "Morning (6am-12pm)"
            case 12..<18: return "Afternoon (12pm-6pm)"
            default: return "Evening (6pm-12am)"
            }
        }
        return groups.mapValues { $0.count }.sorted { $0.key < $1.key }
    }

    private var dayOfWeekCounts: [(String, Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        let groups = Dictionary(grouping: thisWeekTemptations) { temptation -> String in
            formatter.string(from: temptation.timestamp)
        }

        let weekdayOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return weekdayOrder.compactMap { day in
            if let count = groups[day]?.count {
                return (day, count)
            }
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !weeklyData.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly Progress")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                Chart {
                                    ForEach(weeklyData, id: \.weekStart) { data in
                                        BarMark(
                                            x: .value("Week", data.weekStart, unit: .weekOfYear),
                                            y: .value("Count", data.count)
                                        )
                                        .foregroundStyle(.white.opacity(0.7))

                                        LineMark(
                                            x: .value("Week", data.weekStart, unit: .weekOfYear),
                                            y: .value("Goal", data.goal)
                                        )
                                        .foregroundStyle(.red)
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                        .symbol(Circle())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(.white.opacity(0.2))
                                        AxisValueLabel()
                                            .foregroundStyle(.white)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(.white.opacity(0.2))
                                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(height: 250)
                                .padding()
                            }
                            .glassEffect(in: .rect(cornerRadius: 20))
                            .padding(.horizontal)

                            HStack(spacing: 20) {
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.white.opacity(0.7))
                                        .frame(width: 20, height: 12)
                                    Text("Fell Count")
                                        .font(.caption)
                                }

                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(.red)
                                        .frame(width: 20, height: 2)
                                    Text("Goal")
                                        .font(.caption)
                                }
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        }
                    }

                    if !thisWeekTemptations.isEmpty {
                        analyticsSection(title: "By Trigger", data: triggerCounts, icon: "exclamationmark.bubble.fill")
                        analyticsSection(title: "By Time of Day", data: timeOfDayCounts, icon: "clock.fill")
                        analyticsSection(title: "By Day of Week", data: dayOfWeekCounts, icon: "calendar")
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.5))
                            Text("No data yet")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("Start logging temptations to see analytics")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .glassEffect(in: .rect(cornerRadius: 20))
                        .padding(.horizontal)
                    }

                    Spacer()
                        .frame(height: 80)
                }
                .padding(.vertical)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0, green: 0.8, blue: 0.9), Color(red: 0, green: 0.2, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(weeklyGoal: $weeklyGoal)
            }
        }
    }

    @ViewBuilder
    private func analyticsSection(title: String, data: [(String, Int)], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(data, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(item.1)")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassEffect(in: .rect(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LogTemptationView: View {
    @Binding var temptationsData: Data
    @State private var selectedTrigger = ""
    @State private var customTrigger = ""
    @State private var timestamp = Date()
    @State private var showingDatePicker = false
    @Environment(\.dismiss) private var dismiss

    private let commonTriggers = ["Stress", "Boredom", "Social Pressure", "Anxiety", "Habit", "Celebration", "Other"]

    private var timestampFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "@EEE, HH:mm"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)

                            Text("What triggered this temptation?")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding()

                        VStack(spacing: 12) {
                            ForEach(commonTriggers, id: \.self) { trigger in
                                Button {
                                    if trigger == "Other" {
                                        selectedTrigger = ""
                                    } else {
                                        selectedTrigger = trigger
                                    }
                                } label: {
                                    HStack {
                                        Text(trigger)
                                            .fontWeight(.medium)
                                        Spacer()
                                        if selectedTrigger == trigger {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(selectedTrigger == trigger ? .white.opacity(0.2) : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            if !commonTriggers.contains(where: { $0 == selectedTrigger }) || selectedTrigger.isEmpty {
                                TextField("Describe your trigger", text: $customTrigger)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(.white.opacity(0.15))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .tint(.white)
                            }
                        }
                        .padding()
                        .glassEffect(in: .rect(cornerRadius: 20))
                        .padding(.horizontal)

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.vertical)
                }

                VStack(spacing: 0) {
                    Button {
                        logTemptation()
                    } label: {
                        Text("Log Temptation")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundStyle(Color(red: 0, green: 0.5, blue: 0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .disabled(finalTrigger.isEmpty)
                    .opacity(finalTrigger.isEmpty ? 0.5 : 1)
                }
                .background(.ultraThinMaterial)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0, green: 0.8, blue: 0.9), Color(red: 0, green: 0.2, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle(timestampFormatter.string(from: timestamp))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .principal) {
                    Button {
                        showingDatePicker.toggle()
                    } label: {
                        Text(timestampFormatter.string(from: timestamp))
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(timestamp: $timestamp)
            }
        }
    }

    private var finalTrigger: String {
        if !selectedTrigger.isEmpty {
            return selectedTrigger
        }
        return customTrigger.trimmingCharacters(in: .whitespaces)
    }

    private func logTemptation() {
        let trigger = finalTrigger
        guard !trigger.isEmpty else { return }

        var temptations = (try? JSONDecoder().decode([Temptation].self, from: temptationsData)) ?? []
        temptations.append(Temptation(timestamp: timestamp, trigger: trigger))

        if let encoded = try? JSONEncoder().encode(temptations) {
            temptationsData = encoded
        }

        dismiss()
    }
}

struct DatePickerSheet: View {
    @Binding var timestamp: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Time", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()

                Spacer()
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0, green: 0.8, blue: 0.9), Color(red: 0, green: 0.2, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Edit Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Binding var weeklyGoal: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)

                        Text("Weekly Goal")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Set the maximum number of temptations you'll allow yourself each week")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    VStack(spacing: 16) {
                        Text("\(weeklyGoal)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Stepper("", value: $weeklyGoal, in: 0...50)
                            .labelsHidden()
                            .padding()
                            .glassEffect(in: .rect(cornerRadius: 12))
                    }
                    .padding()
                    .glassEffect(in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0, green: 0.8, blue: 0.9), Color(red: 0, green: 0.2, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
