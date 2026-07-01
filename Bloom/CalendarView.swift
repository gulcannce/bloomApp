import SwiftUI
import Combine

struct CalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @ObservedObject var memoryStore = MemoryStore.shared
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedDay: Int? = nil

    let calendar = Calendar.current
    @Environment(\.colorScheme) var colorScheme

    var currentMonthDays: [Int?] {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = 1

        guard let firstDay = calendar.date(from: dateComponents) else { return [] }
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        let daysInMonth = range.count

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let mondayBasedWeekday = (firstWeekday + 5) % 7

        var days: [Int?] = Array(repeating: nil, count: mondayBasedWeekday)
        days.append(contentsOf: (1...daysInMonth).map { $0 })

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var memoryMap: [Int: Memory] {
        var map: [Int: Memory] = [:]
        for memory in memoryStore.memories {
            let memoryMonth = calendar.component(.month, from: memory.date)
            let memoryYear = calendar.component(.year, from: memory.date)
            let memoryDay = calendar.component(.day, from: memory.date)

            if memoryMonth == selectedMonth && memoryYear == selectedYear {
                map[memoryDay] = memory
            }
        }
        return map
    }

    var monthYearString: String {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = 1

        guard let date = calendar.date(from: dateComponents) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "MMMM yyyy" : "MMMM yyyy"
        formatter.locale = localization.currentLanguage == .turkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        return formatter.string(from: date).capitalized
    }

    var monthMemories: [Memory] {
        memoryStore.memories.filter { memory in
            calendar.component(.month, from: memory.date) == selectedMonth &&
            calendar.component(.year, from: memory.date) == selectedYear
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            BloomTheme.agedParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                // PREMIUM MONTH-YEAR HEADER WITH NAVIGATION
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(BloomTheme.driedRose)
                        }
                        .frame(width: 32, height: 32)

                        Spacer()

                        VStack(spacing: 2) {
                            Text(monthYearString)
                                .font(.system(size: 20, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textPrimary)
                                .tracking(0.5)
                        }

                        Spacer()

                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(BloomTheme.driedRose)
                        }
                        .frame(width: 32, height: 32)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // MINIMAL MONTHLY GRID
                        VStack(spacing: 12) {
                            // Day labels row (Mon-Sun)
                            HStack(spacing: 0) {
                                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 10, weight: .light, design: .serif))
                                        .foregroundColor(BloomTheme.textSecondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 16)

                            // Day grid
                            VStack(spacing: 8) {
                                ForEach(0..<(currentMonthDays.count / 7), id: \.self) { weekIndex in
                                    HStack(spacing: 8) {
                                        ForEach(0..<7, id: \.self) { dayIndex in
                                            let dayOptional = currentMonthDays[weekIndex * 7 + dayIndex]

                                            if let day = dayOptional {
                                                ZStack {
                                                    // Highlight circle for days with entries
                                                    if memoryMap[day] != nil {
                                                        Circle()
                                                            .fill(BloomTheme.driedRose.opacity(0.2))
                                                    }

                                                    Text("\(day)")
                                                        .font(.system(size: 13, weight: .light, design: .serif))
                                                        .foregroundColor(memoryMap[day] != nil ? BloomTheme.driedRose : BloomTheme.textPrimary)
                                                }
                                                .frame(height: 32)
                                                .onTapGesture {
                                                    selectedDay = day
                                                }
                                            } else {
                                                Color.clear.frame(height: 32)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // BOTTOM POLAROID MEMORIES GRID
                        VStack(spacing: 12) {
                            if monthMemories.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundColor(BloomTheme.textTertiary)

                                    Text(localization.currentLanguage == .turkish ? "Bu ay için anı yok" : "No memories this month")
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .foregroundColor(BloomTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                // Grid of Polaroid memory cards
                                VStack(spacing: 12) {
                                    ForEach(monthMemories, id: \.id) { memory in
                                        HStack(spacing: 12) {
                                            // Mini Polaroid card
                                            VStack(spacing: 0) {
                                                if let image = memory.image {
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(height: 100)
                                                        .clipped()
                                                } else {
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            BloomTheme.agedParchment,
                                                            BloomTheme.agedParchment.opacity(0.9)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    .frame(height: 100)
                                                }

                                                // Day label
                                                VStack(spacing: 4) {
                                                    let dayComponent = calendar.component(.day, from: memory.date)
                                                    let monthName = getMonthName(selectedMonth)
                                                    Text("\(dayComponent) \(monthName)")
                                                        .font(.system(size: 10, weight: .light, design: .serif))
                                                        .foregroundColor(BloomTheme.textPrimary)
                                                        .italic()

                                                    if !memory.note.isEmpty {
                                                        Text(memory.note.prefix(40) + (memory.note.count > 40 ? "..." : ""))
                                                            .font(.system(size: 9, weight: .light))
                                                            .foregroundColor(BloomTheme.textSecondary)
                                                            .lineLimit(1)
                                                    }
                                                }
                                                .padding(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)

                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }

    private func previousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }

    private func nextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }

    private func getMonthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = localization.currentLanguage == .turkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        guard let date = calendar.date(from: DateComponents(month: month, day: 1)) else { return "" }
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        CalendarView()
            .environmentObject(LocalizationManager())
            .environmentObject(MemoryStore.shared)
    }
}
