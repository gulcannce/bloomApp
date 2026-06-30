import SwiftUI
import Combine

struct AchievementsView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.currentLanguage == .turkish ? "Başarımlar" : "Achievements")
                            .font(.system(size: 32, weight: .thin, design: .serif))
                            .tracking(1.2)
                            .foregroundColor(BloomTheme.textPrimary)

                        Text(localization.currentLanguage == .turkish ? "Senin yolculuğunu kutla" : "Celebrate your journey")
                            .font(.system(size: 13, weight: .light, design: .serif))
                            .italic()
                            .tracking(0.3)
                            .foregroundColor(BloomTheme.textSecondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AchievementBadge(
                            emoji: "🌱",
                            title: localization.currentLanguage == .turkish ? "İlk Adım" : "First Step",
                            condition: localization.currentLanguage == .turkish ? "1 anı kaydet" : "Save 1 memory",
                            isUnlocked: memoryStore.memories.count >= 1
                        )

                        AchievementBadge(
                            emoji: "🔥",
                            title: localization.currentLanguage == .turkish ? "7 Gün Streak" : "7 Day Streak",
                            condition: localization.currentLanguage == .turkish ? "7 gün seri" : "7 day streak",
                            isUnlocked: longestStreak >= 7
                        )

                        AchievementBadge(
                            emoji: "📷",
                            title: localization.currentLanguage == .turkish ? "Fotoğrafçı" : "Photographer",
                            condition: localization.currentLanguage == .turkish ? "En az 1 fotoğraf" : "At least 1 photo",
                            isUnlocked: hasPhotoMemory
                        )

                        AchievementBadge(
                            emoji: "😊",
                            title: localization.currentLanguage == .turkish ? "Mutlu Hafta" : "Happy Week",
                            condition: localization.currentLanguage == .turkish ? "7 pozitif anı" : "7 positive entries",
                            isUnlocked: positiveMemoriesCount >= 7
                        )

                        AchievementBadge(
                            emoji: "✍️",
                            title: localization.currentLanguage == .turkish ? "Yazar" : "Writer",
                            condition: localization.currentLanguage == .turkish ? "50+ sözcük" : "50+ words",
                            isUnlocked: hasLongEntry
                        )

                        AchievementBadge(
                            emoji: "🎉",
                            title: localization.currentLanguage == .turkish ? "100 Giriş" : "100 Entries",
                            condition: localization.currentLanguage == .turkish ? "100 anı" : "100 memories",
                            isUnlocked: memoryStore.memories.count >= 100
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 80)
            }
        }
    }

    private var longestStreak: Int {
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

    private var hasPhotoMemory: Bool {
        memoryStore.memories.contains { $0.image != nil }
    }

    private var positiveMemoriesCount: Int {
        let positiveEmojis = ["🌸", "✨", "🤍"]
        return memoryStore.memories.filter { positiveEmojis.contains($0.emoji) }.count
    }

    private var hasLongEntry: Bool {
        memoryStore.memories.contains { $0.note.split(separator: " ").count > 50 }
    }
}

struct AchievementBadge: View {
    let emoji: String
    let title: String
    let condition: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background glow for unlocked badges
                if isUnlocked {
                    Circle()
                        .fill(BloomTheme.driedRose.opacity(0.1))
                        .frame(width: 70, height: 70)
                }

                Text(emoji)
                    .font(.system(size: 48))
                    .opacity(isUnlocked ? 1.0 : 0.3)
                    .scaleEffect(isUnlocked ? 1.1 : 0.9)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundColor(BloomTheme.textPrimary.opacity(isUnlocked ? 1.0 : 0.4))

                Text(condition)
                    .font(.system(size: 10, weight: .light, design: .serif))
                    .foregroundColor(BloomTheme.textSecondary.opacity(isUnlocked ? 0.8 : 0.3))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 6) {
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(BloomTheme.textTertiary)
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(BloomTheme.driedRose)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isUnlocked ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.white.opacity(0.95)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isUnlocked ? BloomTheme.driedRose.opacity(0.2) : Color.black.opacity(0.05),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: isUnlocked ? BloomTheme.driedRose.opacity(0.15) : Color.black.opacity(0.05),
                    radius: isUnlocked ? 8 : 4,
                    x: 0,
                    y: isUnlocked ? 3 : 1
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isUnlocked)
    }
}
