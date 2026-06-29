import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var memoryStore: MemoryStore
    @State private var expandedMemoryId: UUID? = nil
    @Namespace private var animationNamespace
    @State private var selectedStickerName: String? = nil
    @State private var draggingStickerId: UUID? = nil
    @State private var stickerScale: CGFloat = 1.0
    @State private var stickerRotation: Double = 0
    @State private var showProfileSheet = false
    @State private var showCreateSheet = false

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

                    Button(action: { showProfileSheet = true }) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(Color(red: 0.70, green: 0.65, blue: 0.60))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .sheet(isPresented: $showProfileSheet) {
                    ProfileView()
                        .environmentObject(localization)
                }

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
                        VStack(spacing: 24) {
                            HStack(spacing: 8) {
                                Text("Merhaba,")
                                    .font(.system(size: 36, weight: .light, design: .serif))
                                    .tracking(0.5)
                                    .foregroundColor(BloomTheme.textPrimary)

                                Image(systemName: "leaf.rose")
                                    .font(.system(size: 28, weight: .ultraLight))
                                    .foregroundColor(BloomTheme.driedRose)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    let moods = [
                                        ("Harika", Color(red: 0.85, green: 0.75, blue: 0.80)),
                                        ("İyi", Color(red: 0.80, green: 0.85, blue: 0.78)),
                                        ("Orta", Color(red: 0.88, green: 0.82, blue: 0.70)),
                                        ("Kötü", Color(red: 0.83, green: 0.72, blue: 0.75)),
                                        ("Berbat", Color(red: 0.78, green: 0.68, blue: 0.55))
                                    ]
                                    ForEach(moods, id: \.0) { label, color in
                                        VStack(spacing: 6) {
                                            MoodDoodleFace(mood: label, size: 40)
                                                .frame(width: 40, height: 40)
                                                .background(Circle().fill(color))

                                            Text(label)
                                                .font(.system(size: 10, weight: .light, design: .serif))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        .frame(width: 52)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .frame(height: 80)

                            if let firstMemory = memoryStore.memories.first {
                                VStack(spacing: 16) {
                                    ZStack(alignment: .topTrailing) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                                        VStack(spacing: 0) {
                                            ZStack {
                                                LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                if let image = firstMemory.image {
                                                    image.resizable().scaledToFill()
                                                }
                                            }
                                            .frame(height: 240)
                                            .cornerRadius(8)
                                            .padding(12)

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(firstMemory.note.prefix(80) + (firstMemory.note.count > 80 ? "..." : ""))
                                                    .font(.system(size: 12, weight: .light))
                                                    .lineSpacing(2)
                                                    .foregroundColor(BloomTheme.textPrimary)
                                                    .lineLimit(2)

                                                Text(formattedDate(firstMemory.date))
                                                    .font(.system(size: 10, weight: .light, design: .serif))
                                                    .foregroundColor(BloomTheme.textSecondary)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.bottom, 12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .frame(maxWidth: 320)

                                    HStack(spacing: 8) {
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text("\(longestStreak()) gün streak")
                                                .font(.system(size: 11, weight: .light, design: .serif))
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 10, weight: .ultraLight))
                                        }
                                        .foregroundColor(BloomTheme.textSecondary)
                                        .padding(8)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(6)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                                        expandedMemoryId = firstMemory.id
                                    }
                                }
                            }

                        }
                        .padding(.vertical, 24)

                        Button(action: {
                            showCreateSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .light))
                                Text("Bugünün Öyküsü")
                                    .font(.system(size: 16, weight: .light, design: .serif))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(BloomTheme.driedRose)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
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

                        ScrollView(showsIndicators: false) {
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

                                        ZStack(alignment: .topLeading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(BloomTheme.agedParchment.opacity(0.5))
                                                .frame(height: 140)

                                            ForEach(expandedMemory.stickers) { sticker in
                                                InteractiveStickerView(sticker: sticker)
                                                    .offset(x: sticker.offsetX, y: sticker.offsetY)
                                                    .scaleEffect(sticker.scale)
                                                    .rotationEffect(.degrees(sticker.rotation))
                                                    .gesture(
                                                        SimultaneousGesture(
                                                            DragGesture()
                                                                .onChanged { value in
                                                                    if let index = expandedMemory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                        memoryStore.memories[memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! })!].stickers[index].offsetX = value.translation.width
                                                                        memoryStore.memories[memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! })!].stickers[index].offsetY = value.translation.height
                                                                    }
                                                                },
                                                            SimultaneousGesture(
                                                                MagnificationGesture()
                                                                    .onChanged { value in
                                                                        if let index = expandedMemory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                            memoryStore.memories[memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! })!].stickers[index].scale = value
                                                                        }
                                                                    },
                                                                RotationGesture()
                                                                    .onChanged { value in
                                                                        if let index = expandedMemory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                            memoryStore.memories[memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! })!].stickers[index].rotation = value.degrees
                                                                        }
                                                                    }
                                                            )
                                                        )
                                                    )
                                            }
                                        }
                                        .padding(.top, 8)
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

                        VStack(spacing: 12) {
                            Text("Sticker Tray")
                                .font(.system(size: 12, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(["pressed_daisy", "dried_rose_petal", "vintage_tape", "dried_fern", "wax_seal"], id: \.self) { stickerName in
                                        let botanicalMap = ["pressed_daisy": "🌼", "dried_rose_petal": "🥀", "vintage_tape": "📌", "dried_fern": "🌿", "wax_seal": "✨"]
                                        Button(action: {
                                            if let memoryIndex = memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! }) {
                                                let newSticker = Sticker(name: stickerName)
                                                memoryStore.memories[memoryIndex].stickers.append(newSticker)
                                                memoryStore.saveMemories()
                                            }
                                        }) {
                                            Text(botanicalMap[stickerName] ?? stickerName)
                                                .font(.system(size: 32))
                                                .frame(width: 56, height: 56)
                                                .background(Color.white.opacity(0.6))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .frame(height: 80)
                        }
                        .padding(.vertical, 12)
                    }
                    .background(BloomTheme.cardBackground)
                    .cornerRadius(20)
                    .padding(16)
                    .frame(maxHeight: 700)
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateView()
                .environmentObject(localization)
                .environmentObject(memoryStore)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "dd.MM.yyyy" : "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func longestStreak() -> Int {
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
}

struct InteractiveStickerView: View {
    let sticker: Sticker
    let botanicalStickers = ["pressed_daisy": "🌼", "dried_rose_petal": "🥀", "vintage_tape": "📌", "dried_fern": "🌿", "wax_seal": "✨"]

    var body: some View {
        Text(botanicalStickers[sticker.name] ?? sticker.name)
            .font(.system(size: 28))
            .opacity(0.75)
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
        VStack(spacing: 8) {
            if let image = memory.image {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    image.resizable().scaledToFill()
                }
                .frame(height: 180)
                .cornerRadius(16)
                .clipped()
                .matchedGeometryEffect(id: memory.id, in: animationNamespace)
            }

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
                    .font(.system(size: 12, weight: .light, design: .default))
                    .lineSpacing(2)
                    .foregroundColor(BloomTheme.textPrimary)
                    .lineLimit(3)
            }
            .padding(14)
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

struct HomeViewPreviewContainer: View {
    @StateObject var store = MemoryStore.shared

    var body: some View {
        HomeView()
            .environmentObject(store)
            .environmentObject(LocalizationManager())
            .onAppear {
                let today = Date()
                let calendar = Calendar.current
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
                let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) ?? today
                let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today) ?? today

                let testMemories = [
                    Memory(image: nil, note: "A serene moment.", emoji: "🌸", date: today, stickers: []),
                    Memory(image: nil, note: "This was such a meaningful day with unexpected discoveries and beautiful encounters that I want to remember forever.", emoji: "🌿", date: yesterday, stickers: []),
                    Memory(image: nil, note: "Captured a golden hour.", emoji: "🥀", date: threeDaysAgo, stickers: []),
                    Memory(image: nil, note: "Peaceful reflections.", emoji: "🌾", date: fiveDaysAgo, stickers: [])
                ]
                store.memories = testMemories
            }
    }
}

#Preview {
    HomeViewPreviewContainer()
}
