import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
    @State private var expandedMemoryId: UUID? = nil
    @Namespace private var animationNamespace

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text(localization.string("bloom_title"))
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(BloomTheme.textPrimary)

                    Spacer()

                    Menu {
                        ForEach(Language.allCases, id: \.self) { language in
                            Button(action: {
                                localization.currentLanguage = language
                            }) {
                                HStack {
                                    Text(language.displayName)
                                    if localization.currentLanguage == language {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundColor(BloomTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                if memoryStore.memories.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(BloomTheme.textTertiary)
                        VStack(spacing: 8) {
                            Text(localization.currentLanguage == .turkish ? "Henüz anı yok" : "No memories yet")
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundColor(BloomTheme.textPrimary)
                            Text(localization.currentLanguage == .turkish ? "Create sekmesine git" : "Go to Create tab")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(BloomTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(memoryStore.memories, id: \.id) { memory in
                                PinterestMemoryCard(
                                    memory: memory,
                                    onTap: {
                                        withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                                            expandedMemoryId = memory.id
                                        }
                                    },
                                    animationNamespace: animationNamespace
                                )
                            }
                        }
                        .padding(12)
                    }
                }
            }

            if let expandedId = expandedMemoryId,
               let expandedMemory = memoryStore.memories.first(where: { $0.id == expandedId }) {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                                expandedMemoryId = nil
                            }
                        }

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                                    expandedMemoryId = nil
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose)
                            }
                            .padding(20)
                        }

                        ScrollView {
                            VStack(spacing: 24) {
                                HStack(spacing: 20) {
                                    VStack(spacing: 16) {
                                        ZStack(alignment: .top) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(BloomTheme.agedParchment)
                                                .frame(maxWidth: 140, maxHeight: 180)
                                                .offset(x: 3, y: 4)

                                            if let image = expandedMemory.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Image(systemName: "photo.artframe")
                                                    .font(.system(size: 32, weight: .light))
                                                    .foregroundColor(BloomTheme.textTertiary)
                                            }

                                            RoundedRectangle(cornerRadius: 1.5)
                                                .fill(Color.white.opacity(0.55))
                                                .frame(width: 40, height: 12)
                                                .overlay(RoundedRectangle(cornerRadius: 1.5).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                                                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                                                .offset(y: 6)
                                        }
                                        .frame(width: 140, height: 180)
                                        .matchedGeometryEffect(id: expandedMemory.id, in: animationNamespace)
                                    }

                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(expandedMemory.emoji)
                                            .font(.system(size: 32))

                                        Text(formattedDate(expandedMemory.date))
                                            .font(.system(size: 11, weight: .light, design: .serif))
                                            .foregroundColor(BloomTheme.textSecondary)

                                        Divider()

                                        Text(expandedMemory.note)
                                            .font(.system(size: 13, weight: .light))
                                            .lineSpacing(3)
                                            .foregroundColor(BloomTheme.textPrimary)

                                        if !expandedMemory.stickers.isEmpty {
                                            HStack(spacing: 8) {
                                                ForEach(expandedMemory.stickers, id: \.self) { sticker in
                                                    Text(sticker)
                                                        .font(.system(size: 20))
                                                        .opacity(0.7)
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.05), lineWidth: 1))
                                )
                            }
                            .padding(16)
                        }
                    }
                    .background(BloomTheme.cardBackground)
                    .cornerRadius(20)
                    .padding(16)
                    .frame(maxHeight: 600)
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "dd.MM.yyyy" : "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct PinterestMemoryCard: View {
    @EnvironmentObject var localization: LocalizationManager
    let memory: Memory
    let onTap: () -> Void
    let animationNamespace: Namespace.ID

    var cardHeight: CGFloat {
        let baseHeight: CGFloat = 200
        let noteLength = CGFloat(memory.note.count)
        let additionalHeight = min(noteLength / 50, 2) * 40
        return baseHeight + additionalHeight
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                if let image = memory.image {
                    image.resizable().scaledToFill()
                } else {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(BloomTheme.textTertiary)
                }
            }
            .frame(height: 180)
            .cornerRadius(16)
            .clipped()
            .matchedGeometryEffect(id: memory.id, in: animationNamespace)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(memory.emoji)
                        .font(.system(size: 20))

                    Text(relativeDate(memory.date))
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)

                    Spacer()
                }

                Text(memory.note.prefix(60) + (memory.note.count > 60 ? "..." : ""))
                    .font(.system(size: 12, weight: .light))
                    .lineSpacing(2)
                    .foregroundColor(BloomTheme.textPrimary)
                    .lineLimit(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(BloomTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .onTapGesture(perform: onTap)
    }

    private func relativeDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date, to: now)

        if components.day == 0 {
            return localization.currentLanguage == .turkish ? "Bugün" : "Today"
        } else if components.day == 1 {
            return localization.currentLanguage == .turkish ? "Dün" : "Yesterday"
        } else if let days = components.day, days < 7 {
            return localization.currentLanguage == .turkish ? "\(days) gün önce" : "\(days)d ago"
        } else if let weeks = components.day, weeks < 30 {
            let weekCount = weeks / 7
            return localization.currentLanguage == .turkish ? "\(weekCount) hafta önce" : "\(weekCount)w ago"
        } else if let months = components.month, months < 12 {
            return localization.currentLanguage == .turkish ? "\(months) ay önce" : "\(months)mo ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = localization.currentLanguage == .turkish ? "dd.MM.yy" : "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MemoryStore.shared)
        .environmentObject(LocalizationManager())
        .onAppear {
            MemoryStore.injectMockData()
        }
}
