import SwiftUI
import Combine

struct StatsView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared

    let botanicalMoods = [
        ("🥀", "Kurumuş Gül", "Dried Rose"),
        ("🌿", "Sakin Yaprak", "Calm Leaf"),
        ("🌾", "Huzurlu Tahıl", "Peaceful Grain"),
        ("🌸", "Neşeli Çiçek", "Joyful Bloom"),
        ("🍂", "Düşünücü Yaprak", "Introspective Leaf")
    ]

    var dominantMood: (emoji: String, turkishName: String, count: Int) {
        var counts: [String: Int] = [:]
        for memory in memoryStore.memories {
            counts[memory.emoji, default: 0] += 1
        }

        for (emoji, turkishName, _) in botanicalMoods {
            let count = counts[emoji] ?? 0
            if count > 0 {
                return (emoji, turkishName, count)
            }
        }
        return ("🌸", "Neşeli Çiçek", 0)
    }

    var weekdayFrequency: [Int] {
        var dayCount = Array(repeating: 0, count: 7)
        let calendar = Calendar.current

        for memory in memoryStore.memories {
            let weekday = calendar.component(.weekday, from: memory.date) - 1
            dayCount[weekday] += 1
        }

        return dayCount
    }

    var totalMemories: Int {
        memoryStore.memories.count
    }

    var moodDistribution: [(emoji: String, count: Int)] {
        var counts: [String: Int] = [:]
        for memory in memoryStore.memories {
            counts[memory.emoji, default: 0] += 1
        }

        return botanicalMoods.map { emoji, _, _ in
            (emoji, counts[emoji] ?? 0)
        }.filter { $0.count > 0 }
    }

    var body: some View {
        ZStack {
            BloomTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Text("Duygusal Çiçeklenme Öykün")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(0.5)
                        .foregroundColor(BloomTheme.textPrimary)
                        .padding(.top, 20)

                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Text(dominantMood.emoji)
                                .font(.system(size: 32))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bu ay en çok \(dominantMood.turkishName)")
                                    .font(.system(size: 14, weight: .light, design: .serif))
                                    .foregroundColor(BloomTheme.textPrimary)

                                Text("toplam \(totalMemories) anının \(dominantMood.count) tanesi")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(BloomTheme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(BloomTheme.agedParchment.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Yazma Ritmi")
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textSecondary)
                            .padding(.horizontal, 20)

                        HStack(spacing: 8) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                VStack(spacing: 4) {
                                    Text(["P", "S", "Ç", "P", "C", "C", "P"][dayIndex])
                                        .font(.system(size: 10, weight: .light, design: .serif))
                                        .foregroundColor(BloomTheme.textSecondary)

                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.black.opacity(0.08))

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(weekdayFrequency[dayIndex] > 0 ? BloomTheme.driedRose : BloomTheme.sageGreen.opacity(0.3))
                                            .frame(height: CGFloat(weekdayFrequency[dayIndex]) * 8)
                                    }
                                    .frame(height: 60)

                                    Text("\(weekdayFrequency[dayIndex])")
                                        .font(.system(size: 10, weight: .light))
                                        .foregroundColor(BloomTheme.textTertiary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if !moodDistribution.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duygusal Dağılım")
                                .font(.system(size: 14, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 8) {
                                ForEach(moodDistribution, id: \.emoji) { emoji, count in
                                    let moodLabel = moodEmojiToLabel(emoji)
                                    let moodColor = moodEmojiToColor(emoji)
                                    VStack(spacing: 6) {
                                        MoodDoodleFace(mood: moodLabel, size: 44)
                                            .frame(width: 44, height: 44)
                                            .background(Circle().fill(moodColor))

                                        VStack(spacing: 2) {
                                            Text("\(count)")
                                                .font(.system(size: 12, weight: .light, design: .serif))
                                                .foregroundColor(BloomTheme.textPrimary)
                                            Text(moodLabel)
                                                .font(.system(size: 9, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(BloomTheme.agedParchment.opacity(0.6))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 80)
            }
        }
    }
}

func moodEmojiToLabel(_ emoji: String) -> String {
    switch emoji {
    case "🥀": return "Harika"
    case "🌿": return "İyi"
    case "🌾": return "Orta"
    case "🌸": return "Kötü"
    case "🍂": return "Berbat"
    default: return "Ruh Hali"
    }
}

func moodEmojiToColor(_ emoji: String) -> Color {
    switch emoji {
    case "🥀": return Color(red: 0.85, green: 0.75, blue: 0.80)      // Muted Pink
    case "🌿": return Color(red: 0.80, green: 0.85, blue: 0.78)       // Pale Sage
    case "🌾": return Color(red: 0.88, green: 0.82, blue: 0.70)       // Soft Ochre
    case "🌸": return Color(red: 0.83, green: 0.72, blue: 0.75)       // Muted Rose
    case "🍂": return Color(red: 0.78, green: 0.68, blue: 0.55)       // Autumn Brown
    default: return Color.gray.opacity(0.3)
    }
}

#Preview {
    StatsView()
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
}
