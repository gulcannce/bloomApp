import SwiftUI
import Combine

struct StatsView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared

    var moodData: [(emoji: String, label: String, value: Int)] {
        let botanicalEmojis = [("🥀", "Reflective"), ("🌿", "Calm"), ("🌾", "Peaceful"), ("🌸", "Joyful"), ("🍂", "Introspective")]
        let totalMemories = memoryStore.memories.count
        guard totalMemories > 0 else {
            return botanicalEmojis.map { ($0.0, $0.1, 0) }
        }

        var counts: [String: Int] = [:]
        for memory in memoryStore.memories {
            counts[memory.emoji, default: 0] += 1
        }

        return botanicalEmojis.map { emoji, label in
            let count = counts[emoji] ?? 0
            return (emoji, label, count)
        }
    }

    var longestStreak: Int {
        guard !memoryStore.memories.isEmpty else { return 0 }
        let calendar = Calendar.current
        let dates = Set(memoryStore.memories.map { calendar.startOfDay(for: $0.date) })
        let sortedDates = dates.sorted(by: >)

        var streak = 1
        var maxStreak = 1
        for i in 0..<(sortedDates.count - 1) {
            let current = sortedDates[i]
            let next = sortedDates[i + 1]
            let daysDifference = calendar.dateComponents([.day], from: next, to: current).day ?? 0
            if daysDifference == 1 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 1
            }
        }
        return maxStreak
    }

    var averageMoodEmoji: String {
        var counts: [String: Int] = [:]
        for memory in memoryStore.memories {
            counts[memory.emoji, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "🌸"
    }

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text(localization.string("stats_title"))
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(BloomTheme.textPrimary)
                        .padding(.top, 20)

                    MoodWheelChart(data: moodData)
                        .frame(height: 280)
                        .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(moodData, id: \.1) { emoji, label, value in
                            let totalCount = moodData.reduce(0) { $0 + $1.value }
                            let percentage = totalCount > 0 ? Int((Double(value) / Double(totalCount)) * 100) : 0
                            HStack(spacing: 12) {
                                Text(emoji)
                                    .font(.system(size: 20))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(label)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(BloomTheme.textPrimary)

                                    Text("\(percentage)%")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(BloomTheme.textSecondary)
                                }

                                Spacer()

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black.opacity(0.08))

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black.opacity(0.15))
                                            .frame(width: geo.size.width * CGFloat(percentage) / 100)
                                            .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0), value: percentage)
                                    }
                                }
                                .frame(height: 6)
                                .frame(maxWidth: 100)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)

                    HStack(spacing: 16) {
                        StreakBadge(label: localization.currentLanguage == .turkish ? "Longest Streak" : "Longest Streak", value: "\(longestStreak) Days 🔥")
                        StreakBadge(label: localization.currentLanguage == .turkish ? "Average Mood" : "Average Mood", value: "\(averageMoodEmoji)")
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 80)
            }
        }
    }
}

struct MoodWheelChart: View {
    let data: [(emoji: String, label: String, value: Int)]

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 1)

            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let total = data.reduce(0) { $0 + $1.value }
                    let value = data[index].value
                    let percentage = Double(value) / Double(total)
                    let rotation = data[0..<index].reduce(0.0) { $0 + Double($1.value) / Double(total) * 360 }

                    ZStack {
                        Circle()
                            .trim(from: 0, to: percentage)
                            .stroke(Color.black.opacity(0.1), lineWidth: 20)
                            .rotationEffect(.degrees(rotation - 90))

                        Text(data[index].0)
                            .font(.system(size: 20))
                            .offset(y: -80)
                            .rotationEffect(.degrees(rotation + percentage * 180))
                    }
                }
            }
            .frame(width: 280, height: 280)

            Circle()
                .fill(Color(red: 0.98, green: 0.97, blue: 0.95))
                .frame(width: 80, height: 80)

            Text("RUH\nHALİ")
                .font(.system(size: 14, weight: .light, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.5))
        }
    }
}

struct StreakBadge: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.black.opacity(0.5))

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
