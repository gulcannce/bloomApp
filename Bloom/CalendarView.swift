import SwiftUI
import Combine

struct CalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @ObservedObject var memoryStore = MemoryStore.shared
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    let calendar = Calendar.current

    var currentMonthDays: [Int] {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = 1

        guard let firstDay = calendar.date(from: dateComponents) else { return [] }
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        return Array(1...range.count)
    }

    var memoryMap: [Int: Memory] {
        var map: [Int: Memory] = [:]
        for memory in memoryStore.memories {
            for day in currentMonthDays {
                var dateComponents = DateComponents()
                dateComponents.year = selectedYear
                dateComponents.month = selectedMonth
                dateComponents.day = day

                guard let tileDate = calendar.date(from: dateComponents) else { continue }

                if calendar.isDate(memory.date, inSameDayAs: tileDate) {
                    print("QA_LOG: CalendarView.memoryMap - Mapped memory on day \(day): '\(memory.note.prefix(30))'")
                    map[day] = memory
                }
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
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            BloomTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Button(action: { previousMonth() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(BloomTheme.driedRose)
                        }

                        Text(monthYearString)
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textPrimary)
                            .frame(maxWidth: .infinity)

                        Button(action: { nextMonth() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(BloomTheme.driedRose)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(currentMonthDays, id: \.self) { day in
                            if let tileDate = getTileDate(day: day) {
                                if let dailyEntry = getDailyEntry(for: tileDate) {
                                    NavigationLink(destination: MemoryDetailView(memory: dailyEntry)
                                        .environmentObject(memoryStore)
                                        .environmentObject(localization)
                                    ) {
                                        CalendarTile(
                                            day: day,
                                            tileDate: tileDate,
                                            memoryStore: memoryStore,
                                            sageGreen: BloomTheme.sageGreen
                                        )
                                    }
                                } else {
                                    CalendarTile(
                                        day: day,
                                        tileDate: tileDate,
                                        memoryStore: memoryStore,
                                        sageGreen: BloomTheme.sageGreen
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 80)
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

    private func getTileDate(day: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = day
        return calendar.date(from: dateComponents)
    }

    private func getDailyEntry(for tileDate: Date) -> Memory? {
        memoryStore.memories.first { memory in
            calendar.isDate(memory.date, inSameDayAs: tileDate)
        }
    }
}

struct CalendarTile: View {
    let day: Int
    let tileDate: Date
    @ObservedObject var memoryStore: MemoryStore
    let sageGreen: Color
    let calendar = Calendar.current

    var dailyEntry: Memory? {
        memoryStore.memories.first { memory in
            calendar.isDate(memory.date, inSameDayAs: tileDate)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.96, green: 0.94, blue: 0.91), Color(red: 0.96, green: 0.94, blue: 0.91).opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if let entry = dailyEntry, let image = entry.image {
                    image.resizable().scaledToFill()
                        .onAppear {
                            print("QA_LOG: CalendarTile - Rendering image for day \(day)")
                        }
                } else {
                    VStack {
                        Image(systemName: "leaf")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(sageGreen.opacity(0.4))
                    }
                }
            }
            .frame(height: 80)
            .cornerRadius(8)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("\(day)")
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundColor(Color.black.opacity(0.8))

                    if let entry = dailyEntry {
                        let symbolName = moodEmojiToSymbol(entry.emoji)
                        Image(systemName: symbolName)
                            .font(.system(size: 11, weight: .ultraLight))
                            .foregroundColor(sageGreen.opacity(0.7))
                    }

                    Spacer()
                }

                if let entry = dailyEntry {
                    Text(entry.note.prefix(40) + (entry.note.count > 40 ? "..." : ""))
                        .font(.system(size: 9, weight: .light))
                        .foregroundColor(Color.black.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

func moodEmojiToSymbol(_ emoji: String) -> String {
    switch emoji {
    case "🌸": return "leaf.rose"
    case "🌿": return "leaf"
    case "🌾": return "sun.haze"
    case "🍂": return "drop"
    case "🥀": return "wind"
    default: return "leaf"
    }
}

#Preview {
    CalendarView()
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
}
