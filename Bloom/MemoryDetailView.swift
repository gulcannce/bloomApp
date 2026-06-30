import SwiftUI
import Combine

struct PlacedSticker: Identifiable {
    let id: UUID
    let name: String
    var offset: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Double = 0

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

struct MemoryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var localization: LocalizationManager
    @State var memory: Memory
    @State private var editingNote = ""
    @State private var placedStickers: [PlacedSticker] = []
    @State private var activeStickerId: UUID? = nil
    @Namespace private var animationNamespace

    let stickerMap = [
        "daisy": "🌼",
        "rose": "🌹",
        "sunflower": "🌻",
        "tulip": "🌷",
        "hibiscus": "🌺",
        "cherry": "🌸",
        "bouquet": "💐",
        "leaf": "🌿",
        "autumn": "🍂",
        "coffee": "☕",
        "candle": "🕯️",
        "tea": "🫖",
        "camera": "📷",
        "laptop": "💻",
        "book": "📚",
        "headphones": "🎧",
        "heart": "🤎",
        "pink_heart": "🩷",
        "bow": "🎀",
        "lipstick": "💄",
        "perfume": "💐",
        "handbag": "👜",
        "shoe": "👠",
        "dress": "👗",
        "airplane": "✈️",
        "luggage": "🧳",
        "passport": "🛂",
        "butterfly": "🦋",
        "bee": "🐝",
        "dog": "🐕",
        "teddy": "🧸",
        "croissant": "🥐",
        "cake": "🍰",
        "cupcake": "🧁",
        "cookie": "🍪",
        "popcorn": "🍿",
        "star": "⭐",
        "sparkle": "✨",
        "moon": "🌙",
        "ribbon": "🎁",
        "bell": "🔔",
        "fox": "🦊",
        "love_letter": "💌"
    ]

    var body: some View {
        ZStack {
            Color("IvoryParchment").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Button(action: { saveAndDismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .thin))
                            .foregroundColor(BloomTheme.textSecondary)
                    }

                    Spacer()

                    Text(formattedDate(memory.date))
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)

                    Spacer()

                    Color.clear.frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color("IvoryParchment"))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        PolaroidCarouselView(memory: $memory)
                            .matchedGeometryEffect(id: memory.id, in: animationNamespace)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

                            // Multiple images support with TabView
                            if !memory.images.isEmpty {
                                TabView {
                                    ForEach(0..<memory.images.count, id: \.self) { index in
                                        memory.images[index].resizable()
                                            .scaledToFill()
                                            .clipped()
                                            .cornerRadius(12)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .automatic))
                            } else if let image = memory.image {
                                image.resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .cornerRadius(12)
                            }

                            ForEach(placedStickers) { sticker in
                                buildStickerView(sticker)
                                    .zIndex(100)
                            }
                        }
                        .frame(height: 280)
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Senin Anın")
                                .font(.system(size: 13, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal, 20)

                            TextEditor(text: $editingNote)
                                .font(.system(size: 14, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textPrimary)
                                .frame(minHeight: 120)
                                .lineSpacing(6)
                                .padding(16)
                                .background(Color("IvoryParchment").opacity(0.5))
                                .cornerRadius(0)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.vertical, 24)
                }

                VStack(spacing: 12) {
                    Text("Günün Çıkartmaları")
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                        .tracking(0.5)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(stickerMap.keys.sorted(), id: \.self) { stickerName in
                                Button(action: {
                                    let newSticker = PlacedSticker(name: stickerName)
                                    placedStickers.append(newSticker)
                                    activeStickerId = newSticker.id
                                    print("QA_LOG: MemoryDetailView - Added sticker: \(stickerName)")
                                }) {
                                    getStickerIconForDetail(stickerName)
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundColor(getStickerColorForDetail(stickerName))
                                        .frame(width: 48, height: 48)
                                        .background(Circle().fill(Color.white.opacity(0.6)))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 64)
                }
                .padding(.vertical, 12)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            editingNote = memory.note
        }
    }

    @ViewBuilder
    private func buildStickerView(_ sticker: PlacedSticker) -> some View {
        Text(stickerMap[sticker.name] ?? sticker.name)
            .font(.system(size: 28))
            .opacity(0.8)
            .offset(x: sticker.offset.x, y: sticker.offset.y)
            .scaleEffect(sticker.scale)
            .rotationEffect(.degrees(sticker.rotation))
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                placedStickers[index].offset = CGPoint(x: value.translation.width, y: value.translation.height)
                                activeStickerId = sticker.id
                            }
                        }
                        .onEnded { _ in
                            print("QA_LOG: MemoryDetailView - Sticker drag ended")
                        },
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                    placedStickers[index].scale = value
                                    activeStickerId = sticker.id
                                }
                            },
                        RotationGesture()
                            .onChanged { value in
                                if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                    placedStickers[index].rotation = value.degrees
                                    activeStickerId = sticker.id
                                }
                            }
                    )
                )
            )
    }

    private func saveAndDismiss() {
        memory.note = editingNote
        if let index = memoryStore.memories.firstIndex(where: { $0.id == memory.id }) {
            memoryStore.memories[index] = memory
            memoryStore.saveMemories()
            print("QA_LOG: MemoryDetailView - Saved memory with \(placedStickers.count) placed stickers")
        }
        presentationMode.wrappedValue.dismiss()
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

    private func getStickerIconForDetail(_ name: String) -> Image {
        switch name {
        case "bow", "ribbon":
            return Image(systemName: "ribbon")
        case "flower", "cherry", "daisy", "rose":
            return Image(systemName: "camera.macro")
        case "sparkle", "candle":
            return Image(systemName: "sparkles")
        case "coffee", "tea":
            return Image(systemName: "cup.and.saucer")
        case "heart", "pink_heart":
            return Image(systemName: "heart")
        case "book", "bouquet", "tulip", "hibiscus", "sunflower":
            return Image(systemName: "book")
        case "headphones":
            return Image(systemName: "headphones")
        case "camera":
            return Image(systemName: "camera")
        case "laptop":
            return Image(systemName: "laptop")
        case "handbag", "luggage":
            return Image(systemName: "handbag")
        case "shoe":
            return Image(systemName: "shoe")
        case "dress":
            return Image(systemName: "tshirt")
        case "airplane":
            return Image(systemName: "airplane")
        case "passport":
            return Image(systemName: "passport")
        case "butterfly":
            return Image(systemName: "butterfly")
        case "bee":
            return Image(systemName: "hare")
        case "dog", "teddy":
            return Image(systemName: "dog")
        case "croissant":
            return Image(systemName: "fork.knife")
        case "cake", "cupcake":
            return Image(systemName: "birthday.cake")
        case "cookie":
            return Image(systemName: "cookies")
        case "popcorn":
            return Image(systemName: "popcorn")
        case "star":
            return Image(systemName: "star")
        case "moon":
            return Image(systemName: "moon")
        case "bell":
            return Image(systemName: "bell")
        case "fox":
            return Image(systemName: "dog.circle")
        case "love_letter":
            return Image(systemName: "envelope")
        case "leaf", "autumn":
            return Image(systemName: "leaf")
        default:
            return Image(systemName: "sparkles")
        }
    }

    private func getStickerColorForDetail(_ name: String) -> Color {
        switch name {
        case "bow", "ribbon", "pink_heart", "rose", "hibiscus", "lipstick":
            return Color(red: 0.83, green: 0.64, blue: 0.64)
        case "sparkle", "candle", "star", "sun", "cake", "cupcake":
            return Color(red: 0.83, green: 0.69, blue: 0.22)
        case "coffee", "tea", "croissant", "popcorn", "dog":
            return Color(red: 0.74, green: 0.66, blue: 0.54)
        case "flower", "daisy", "cherry", "tulip", "bouquet", "book":
            return Color(red: 0.89, green: 0.75, blue: 0.82)
        case "leaf", "autumn":
            return Color(red: 0.66, green: 0.70, blue: 0.63)
        default:
            return Color(red: 0.80, green: 0.81, blue: 0.81)
        }
    }
}

struct PolaroidCarouselView: View {
    @Binding var memory: Memory

    var body: some View {
        VStack(spacing: 12) {
            if let image = memory.image {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                    VStack(spacing: 0) {
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .cornerRadius(8)
                            .padding(12)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(memory.note.prefix(60) + (memory.note.count > 60 ? "..." : ""))
                                .font(.system(size: 11, weight: .light))
                                .lineSpacing(2)
                                .foregroundColor(BloomTheme.textPrimary)
                                .lineLimit(2)

                            Text(memory.emoji)
                                .font(.system(size: 20))
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: 280)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    let testMemory = Memory(image: nil, note: "Test memory", emoji: "🌸", stickers: [])
    MemoryDetailView(memory: testMemory)
        .environmentObject(MemoryStore.shared)
        .environmentObject(LocalizationManager())
}
