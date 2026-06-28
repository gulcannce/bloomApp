import SwiftUI
import Combine

struct CalendarView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
    let currentDate = Date()

    var sortedMemories: [Memory] {
        memoryStore.memories.sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text(localization.string("calendar_title"))
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.top, 20)

                    MonthlyCalendarGrid(memories: memoryStore.memories)
                        .padding(.horizontal, 16)

                    Divider()
                        .padding(.horizontal, 16)

                    if memoryStore.memories.isEmpty {
                        VStack(spacing: 12) {
                            Text(localization.currentLanguage == .turkish ? "Henüz anı yok" : "No memories yet")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(localization.currentLanguage == .turkish ? "Anılar" : "Memories")
                                .font(.system(size: 16, weight: .light, design: .serif))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.horizontal, 16)

                            ForEach(sortedMemories, id: \.id) { memory in
                                MemoryTimelineItem(
                                    date: formatDateForTimeline(memory.date),
                                    snippet: memory.note.prefix(60) + (memory.note.count > 60 ? "..." : ""),
                                    emoji: memory.emoji
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 80)
            }
        }
    }

    private func formatDateForTimeline(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "dd MMMM yyyy" : "MMMM dd, yyyy"
        formatter.locale = localization.currentLanguage == .turkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct MonthlyCalendarGrid: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    let memories: [Memory]
    let calendar = Calendar.current

    var daysWithMemories: [Int] {
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        var days: [Int] = []
        for memory in memories {
            let memoryMonth = calendar.component(.month, from: memory.date)
            let memoryYear = calendar.component(.year, from: memory.date)
            if memoryMonth == currentMonth && memoryYear == currentYear {
                let day = calendar.component(.day, from: memory.date)
                days.append(day)
            }
        }
        return Array(Set(days)).sorted()
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(["Paz", "Pts", "Sal", "Çrş", "Prş", "Cum", "Ctsi"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.black.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...30, id: \.self) { day in
                    ZStack {
                        if daysWithMemories.contains(day) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.08))
                                .transition(.scale.combined(with: .opacity))
                        }

                        VStack(spacing: 2) {
                            Text("\(day)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.black.opacity(0.7))

                            if daysWithMemories.contains(day) {
                                Text(emojiForDay(day))
                                    .font(.system(size: 10))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: 50)
                    .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0), value: daysWithMemories)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }

    private func emojiForDay(_ day: Int) -> String {
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        for memory in memories {
            let memoryMonth = calendar.component(.month, from: memory.date)
            let memoryYear = calendar.component(.year, from: memory.date)
            let memoryDay = calendar.component(.day, from: memory.date)

            if memoryMonth == currentMonth && memoryYear == currentYear && memoryDay == day {
                return memory.emoji
            }
        }
        return "📷"
    }
}

struct MemoryTimelineItem: View {
    let date: String
    let snippet: String
    let emoji: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Color.black.opacity(0.08)
                Text(emoji)
                    .font(.system(size: 24))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .foregroundColor(.black.opacity(0.5))

                Text(snippet)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
    }
}
