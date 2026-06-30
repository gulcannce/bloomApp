import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var memoryStore = MemoryStore.shared
    @EnvironmentObject var localization: LocalizationManager

    let pastelColors = [
        Color(red: 0.85, green: 0.75, blue: 0.80),  // Pastel Rose
        Color(red: 0.80, green: 0.85, blue: 0.78),  // Pastel Green
        Color(red: 0.88, green: 0.82, blue: 0.70),  // Pastel Gold
        Color(red: 0.83, green: 0.72, blue: 0.75),  // Pastel Mauve
    ]

    let moodEmojis = ["🌸": "Harika", "🌿": "Sakin", "🌾": "Dengeli", "🥀": "Yorgun"]
    let moodLabels = ["🌸", "🌿", "🌾", "🥀"]

    var moodDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        for memory in memoryStore.memories {
            distribution[memory.emoji, default: 0] += 1
        }
        return distribution
    }

    var totalMemories: Int {
        memoryStore.memories.count
    }

    var topMood: (emoji: String, count: Int, label: String)? {
        let sorted = moodDistribution.sorted { $0.value > $1.value }
        if let top = sorted.first {
            return (top.key, top.value, moodEmojis[top.key] ?? top.key)
        }
        return nil
    }

    var recordingRate: Int {
        guard totalMemories > 0 else { return 0 }
        return min(100, (totalMemories * 100) / 30)
    }

    var body: some View {
        ZStack {
            BloomTheme.agedParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analiz")
                        .font(.system(size: 32, weight: .thin, design: .serif))
                        .tracking(1.2)
                        .foregroundColor(BloomTheme.textPrimary)

                    Text("Duygularının mevsimleri")
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .italic()
                        .tracking(0.3)
                        .foregroundColor(BloomTheme.textSecondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if totalMemories == 0 {
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "chart.pie")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(BloomTheme.textTertiary)
                                Text(localization.currentLanguage == .turkish ? "Henüz veri yok" : "No data yet")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(BloomTheme.textSecondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            MoodChartView(
                                distribution: moodDistribution,
                                moodLabels: moodLabels,
                                moodEmojis: moodEmojis,
                                pastelColors: pastelColors,
                                totalMemories: totalMemories
                            )

                            VStack(spacing: 12) {
                                if let top = topMood {
                                    InsightCard(
                                        title: localization.currentLanguage == .turkish ? "Bu ay en çok" : "Most frequent",
                                        emoji: top.emoji,
                                        value: "\(top.count) gün",
                                        subtitle: top.label
                                    )
                                }

                                InsightCard(
                                    title: localization.currentLanguage == .turkish ? "Duygu Kayıt Oranı" : "Recording Rate",
                                    emoji: "📊",
                                    value: "%\(recordingRate)",
                                    subtitle: localization.currentLanguage == .turkish ? "30 günde" : "per 30 days"
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
        }
    }
}

struct MoodChartView: View {
    let distribution: [String: Int]
    let moodLabels: [String]
    let moodEmojis: [String: String]
    let pastelColors: [Color]
    let totalMemories: Int

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(BloomTheme.agedParchment.opacity(0.5))
                    .frame(width: 200, height: 200)

                VStack(spacing: 4) {
                    Text("\(totalMemories)")
                        .font(.system(size: 36, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textPrimary)
                    Text("anı")
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                }

                Canvas { context, size in
                    var startAngle: Double = -90
                    for (index, emoji) in moodLabels.enumerated() {
                        let count = distribution[emoji] ?? 0
                        let percentage = count > 0 ? Double(count) / Double(totalMemories) : 0
                        let sliceAngle = percentage * 360

                        var path = Path()
                        path.addArc(
                            center: CGPoint(x: 100, y: 100),
                            radius: 95,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(startAngle + sliceAngle),
                            clockwise: false
                        )
                        path.addLine(to: CGPoint(x: 100, y: 100))
                        path.closeSubpath()

                        context.fill(path, with: .color(pastelColors[index % pastelColors.count]))
                        startAngle += sliceAngle
                    }
                }
                .frame(width: 200, height: 200)
            }

            HStack(spacing: 16) {
                ForEach(moodLabels, id: \.self) { emoji in
                    VStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 24))
                        Text("\(distribution[emoji] ?? 0)")
                            .font(.system(size: 11, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textSecondary)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct InsightCard: View {
    let title: String
    let emoji: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)

                    HStack(spacing: 0) {
                        Text(value)
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textPrimary)

                        Text(" \(subtitle)")
                            .font(.system(size: 11, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.4))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(MemoryStore.shared)
        .environmentObject(LocalizationManager())
}
