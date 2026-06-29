import SwiftUI
import Combine

struct CalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
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
            let day = calendar.component(.day, from: memory.date)
            let month = calendar.component(.month, from: memory.date)
            let year = calendar.component(.year, from: memory.date)

            if month == selectedMonth && year == selectedYear {
                map[day] = memory
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
                            CalendarTile(
                                day: day,
                                memory: memoryMap[day],
                                sageGreen: BloomTheme.sageGreen
                            )
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
}

struct CalendarTile: View {
    let day: Int
    let memory: Memory?
    let sageGreen: Color

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.96, green: 0.94, blue: 0.91), Color(red: 0.96, green: 0.94, blue: 0.91).opacity(0.9)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if let memory = memory, let image = memory.image {
                    image.resizable().scaledToFill()
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

            HStack(spacing: 6) {
                Text("\(day)")
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundColor(Color.black.opacity(0.8))

                if let memory = memory {
                    let symbolName = moodEmojiToSymbol(memory.emoji)
                    Image(systemName: symbolName)
                        .font(.system(size: 11, weight: .ultraLight))
                        .foregroundColor(sageGreen.opacity(0.7))
                }

                Spacer()
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
