import SwiftUI
import PhotosUI

struct HomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var createViewState: CreateViewState
    @Binding var showCreateSheet: Bool
    @State private var expandedMemoryId: UUID? = nil
    @Namespace private var animationNamespace
    @State private var selectedStickerName: String? = nil
    @State private var draggingStickerId: UUID? = nil
    @State private var stickerScale: CGFloat = 1.0
    @State private var stickerRotation: Double = 0
    @State private var showProfileSheet = false
    @State private var localSelectedItem: PhotosPickerItem? = nil
    @State private var selectedMood: String? = nil
    @Environment(\.colorScheme) var colorScheme

    private let moods: [(label: String, emoji: String, color: Color)] = [
        ("Harika", "face.smiling.fill", Color(red: 0.92, green: 0.58, blue: 0.58)),
        ("İyi",    "face.smiling.fill", Color(red: 0.90, green: 0.72, blue: 0.45)),
        ("Orta",   "face.neutral.fill", Color(red: 0.72, green: 0.72, blue: 0.65)),
        ("Kötü",   "face.frowning.fill", Color(red: 0.85, green: 0.55, blue: 0.45)),
        ("Berbat", "heart.broken.fill", Color(red: 0.70, green: 0.50, blue: 0.55))
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            BloomTheme.adaptiveBackground(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Merhaba, 🌸")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .tracking(0.5)
                            .foregroundColor(BloomTheme.textPrimary)

                        Text("Bugün kendini nasıl hissediyorsun?")
                            .font(.system(size: 12, weight: .light, design: .serif))
                            .tracking(0.2)
                            .foregroundColor(BloomTheme.textSecondary.opacity(0.7))
                    }

                    Spacer()

                    Button(action: { showProfileSheet = true }) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .sheet(isPresented: $showProfileSheet) {
                    ProfileView()
                        .environmentObject(localization)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Mood selector row — always visible
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(moods, id: \.label) { mood in
                                    Button(action: {
                                        selectedMood = selectedMood == mood.label ? nil : mood.label
                                        print("QA_LOG: Mood selected: \(mood.label)")
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: mood.emoji)
                                                .font(.system(size: 32, weight: .medium))
                                                .foregroundColor(mood.color)
                                                .frame(width: 52, height: 52)
                                                .background(
                                                    Circle()
                                                        .fill(Color.white)
                                                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
                                                )
                                                .overlay(
                                                    Circle().stroke(
                                                        selectedMood == mood.label ? mood.color : Color.clear,
                                                        lineWidth: 2
                                                    )
                                                )
                                                .scaleEffect(selectedMood == mood.label ? 1.08 : 1.0)

                                            Text(mood.label)
                                                .font(.system(size: 10, weight: .light, design: .serif))
                                                .foregroundColor(selectedMood == mood.label ? mood.color : BloomTheme.textSecondary)
                                        }
                                        .frame(width: 64)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(height: 90)

                        if memoryStore.memories.isEmpty {
                            VStack(spacing: 16) {
                                Spacer(minLength: 40)
                                Image(systemName: "photo.artframe")
                                    .font(.system(size: 48, weight: .ultraLight))
                                    .foregroundColor(BloomTheme.textTertiary)
                                VStack(spacing: 6) {
                                    Text(localization.currentLanguage == .turkish ? "Henüz anı yok" : "No memories yet")
                                        .font(.system(size: 16, weight: .light, design: .serif))
                                        .foregroundColor(BloomTheme.textPrimary)
                                    Text(localization.currentLanguage == .turkish ? "İlk anını eklemek için ✏️ Bugün Yaz'a dokun" : "Tap ✏️ Write Today to add your first memory")
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .foregroundColor(BloomTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer(minLength: 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                        } else {

                            // Hero Polaroid card
                            if let latestMemory = memoryStore.memories.sorted(by: { $0.date > $1.date }).first {
                                ZStack(alignment: .bottomTrailing) {
                                    // Polaroid white frame
                                    VStack(spacing: 0) {
                                        // Photo area with seamless fill
                                        if let image = latestMemory.image {
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(height: 240)
                                                .clipped()
                                        } else {
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.96, green: 0.94, blue: 0.91),
                                                    Color(red: 0.90, green: 0.88, blue: 0.85)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .frame(height: 240)
                                        }

                                        // Caption section
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Küçük şeyler, büyük mutluluklar.")
                                                .font(.system(size: 14, weight: .light, design: .serif))
                                                .italic()
                                                .tracking(0.6)
                                                .lineSpacing(2)
                                                .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.25))

                                            Text(formattedDate(latestMemory.date))
                                                .font(.system(size: 11, weight: .light, design: .serif))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                                    // Botanical daisy accent overlay on Polaroid
                                    Image(systemName: "leaf.circle")
                                        .font(.system(size: 28, weight: .thin))
                                        .foregroundColor(Color(red: 0.75, green: 0.80, blue: 0.70).opacity(0.5))
                                        .padding(.trailing, 8)
                                        .padding(.bottom, 28)

                                    // Streak badge overlaid at bottom-right corner of Polaroid
                                    HStack(spacing: 4) {
                                        Text("🔥")
                                            .font(.system(size: 12))
                                        Text("12 gün streak")
                                            .font(.system(size: 11, weight: .medium, design: .serif))
                                            .foregroundColor(BloomTheme.driedRose)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0.98, green: 0.95, blue: 0.93))
                                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                                    )
                                    .padding(.trailing, 16)
                                    .padding(.bottom, 12)
                                }
                                .padding(.horizontal, 20)
                            } // end if let latestMemory
                        } // end if !memories.isEmpty else block

                        // "Bugünün Öyküsü" primary CTA button — always visible
                        PhotosPicker(selection: $localSelectedItem, matching: .images) {
                            HStack(spacing: 8) {
                                Text("✏️")
                                    .font(.system(size: 16))
                                Text("Bugünün Öyküsü")
                                    .font(.system(size: 16, weight: .light, design: .serif))
                                    .tracking(0.3)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(BloomTheme.driedRose)
                            .cornerRadius(12)
                            .shadow(color: BloomTheme.driedRose.opacity(0.35), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                    }
                    .padding(.vertical, 12)
                }
                .padding(.bottom, 90)
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
                                                buildStickerView(sticker, from: expandedMemory)
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
        .onChange(of: localSelectedItem) {
            Task {
                if let newItem = localSelectedItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                print("QA_LOG: HomeView photo picker - Image loaded and set to createViewState")
                                createViewState.processedImage = Image(uiImage: uiImage)
                                print("QA_LOG: HomeView photo picker - Opening CreateView sheet with image")
                                showCreateSheet = true
                            }
                        }
                    }
                }
            }
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

    @ViewBuilder
    private func buildStickerView(_ sticker: Sticker, from memory: Memory) -> some View {
        InteractiveStickerView(sticker: sticker)
            .offset(x: sticker.offsetX, y: sticker.offsetY)
            .scaleEffect(sticker.scale)
            .rotationEffect(.degrees(sticker.rotation))
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if let index = memory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                if let memoryIndex = memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! }) {
                                    memoryStore.memories[memoryIndex].stickers[index].offsetX = value.translation.width
                                    memoryStore.memories[memoryIndex].stickers[index].offsetY = value.translation.height
                                }
                            }
                        },
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if let index = memory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                    if let memoryIndex = memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! }) {
                                        memoryStore.memories[memoryIndex].stickers[index].scale = value
                                    }
                                }
                            },
                        RotationGesture()
                            .onChanged { value in
                                if let index = memory.stickers.firstIndex(where: { $0.id == sticker.id }) {
                                    if let memoryIndex = memoryStore.memories.firstIndex(where: { $0.id == expandedMemoryId! }) {
                                        memoryStore.memories[memoryIndex].stickers[index].rotation = value.degrees
                                    }
                                }
                            }
                    )
                )
            )
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
    @State private var showCreateSheet = false

    var body: some View {
        HomeView(showCreateSheet: $showCreateSheet)
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
