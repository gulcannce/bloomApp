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

    let stickerMap = ["dried_daisy": "🌼", "vintage_seal": "🪞", "mini_heart": "🤎", "candlelight": "✨"]
    let stickerAssets = ["dried_daisy", "vintage_seal", "mini_heart", "candlelight"]

    var body: some View {
        ZStack {
            BloomTheme.agedParchment.ignoresSafeArea()

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
                .background(BloomTheme.agedParchment)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        PolaroidCarouselView(memory: $memory)
                            .matchedGeometryEffect(id: memory.id, in: animationNamespace)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

                            if let image = memory.image {
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
                                .background(BloomTheme.agedParchment.opacity(0.5))
                                .cornerRadius(0)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.vertical, 24)
                }

                VStack(spacing: 12) {
                    Text("Günün Çıkartmaları")
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                        .tracking(0.4)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(stickerAssets, id: \.self) { stickerName in
                                Button(action: {
                                    let newSticker = PlacedSticker(name: stickerName)
                                    placedStickers.append(newSticker)
                                    activeStickerId = newSticker.id
                                    print("QA_LOG: MemoryDetailView - Added sticker: \(stickerName)")
                                }) {
                                    Text(stickerMap[stickerName] ?? stickerName)
                                        .font(.system(size: 32))
                                        .frame(width: 52, height: 52)
                                        .background(Color.white.opacity(0.4))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 68)
                }
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.2))
                .ignoresSafeArea(edges: .bottom)
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
