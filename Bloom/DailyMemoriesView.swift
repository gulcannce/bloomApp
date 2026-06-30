import SwiftUI

struct DailyMemoriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var localization: LocalizationManager
    let selectedDate: Date
    let calendar = Calendar.current

    var dailyMemories: [Memory] {
        memoryStore.memories.filter { memory in
            calendar.isDate(memory.date, inSameDayAs: selectedDate)
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            BloomTheme.agedParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .thin))
                            .foregroundColor(BloomTheme.textSecondary)
                    }

                    Spacer()

                    Text(formattedDate(selectedDate))
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)

                    Spacer()

                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(BloomTheme.agedParchment)

                if dailyMemories.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(BloomTheme.textTertiary)
                        Text(localization.currentLanguage == .turkish ? "Bu gün için anı yok" : "No memories for this day")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(BloomTheme.textSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(dailyMemories, id: \.id) { memory in
                                NavigationLink(destination: MemoryDetailView(memory: memory)
                                    .environmentObject(memoryStore)
                                    .environmentObject(localization)
                                ) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        if let image = memory.image {
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 200)
                                                .cornerRadius(12)
                                                .clipped()
                                        }

                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 8) {
                                                Text(memory.emoji)
                                                    .font(.system(size: 18))

                                                Text(formattedTime(memory.date))
                                                    .font(.system(size: 11, weight: .light, design: .serif))
                                                    .foregroundColor(BloomTheme.textSecondary)

                                                Spacer()
                                            }

                                            Text(memory.note)
                                                .font(.system(size: 12, weight: .light))
                                                .lineSpacing(2)
                                                .foregroundColor(BloomTheme.textPrimary)
                                                .lineLimit(3)
                                        }
                                        .padding(12)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if localization.currentLanguage == .turkish {
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "tr_TR")
            let dateStr = formatter.string(from: date)
            return dateStr.capitalized
        } else {
            formatter.dateFormat = "MMMM dd, yyyy"
            return formatter.string(from: date)
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DailyMemoriesView(selectedDate: Date())
            .environmentObject(MemoryStore.shared)
            .environmentObject(LocalizationManager())
    }
}
