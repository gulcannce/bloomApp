import SwiftUI
import PhotosUI
import UIKit

struct CreateView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
    @Environment(\.dismiss) var dismiss

    @State private var journalText: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var selectedMoodEmoji: String = "🌸"
    @State private var placedStickers: [Sticker] = []

    let moodSymbols = ["🥀", "🌿", "🌾", "🌸", "🍂"]
    let botanicalStickers = [
        ("pressed_daisy", "🌼"),
        ("dried_rose_petal", "🥀"),
        ("vintage_tape", "📌"),
        ("dried_fern", "🌿"),
        ("wax_seal", "✨")
    ]

    var body: some View {
        ZStack {
            BloomTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                    }
                    Spacer()
                    Button(action: saveMemory) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                    }
                }
                .padding(20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                            VStack(spacing: 0) {
                                ZStack(alignment: .center) {
                                    LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                                    if let image = processedImage {
                                        image.resizable().scaledToFill()
                                    } else {
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo.artframe")
                                                .font(.system(size: 48, weight: .light))
                                                .foregroundColor(BloomTheme.textTertiary)
                                            Text("Fotoğraf Ekle")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                    }

                                    ForEach(placedStickers) { sticker in
                                        Text(getEmojiForSticker(sticker.name))
                                            .font(.system(size: 24))
                                            .offset(x: sticker.offsetX, y: sticker.offsetY)
                                            .scaleEffect(sticker.scale)
                                            .rotationEffect(.degrees(sticker.rotation))
                                            .gesture(
                                                SimultaneousGesture(
                                                    DragGesture()
                                                        .onChanged { value in
                                                            if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                placedStickers[index].offsetX = value.translation.width
                                                                placedStickers[index].offsetY = value.translation.height
                                                            }
                                                        },
                                                    SimultaneousGesture(
                                                        MagnificationGesture()
                                                            .onChanged { value in
                                                                if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                    placedStickers[index].scale = min(max(value, 0.5), 3.0)
                                                                }
                                                            },
                                                        RotationGesture()
                                                            .onChanged { value in
                                                                if let index = placedStickers.firstIndex(where: { $0.id == sticker.id }) {
                                                                    placedStickers[index].rotation = value.degrees
                                                                }
                                                            }
                                                    )
                                                )
                                            )
                                    }
                                }
                                .frame(height: 240)
                                .cornerRadius(8)
                                .padding(12)

                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Bugün'ün Öyküsü", text: $journalText)
                                        .font(.system(size: 12, weight: .light))
                                        .lineSpacing(2)
                                        .foregroundColor(BloomTheme.textPrimary)
                                        .padding(8)
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: 320)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bugün'ün Hali")
                                .font(.system(size: 12, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)

                            HStack(spacing: 8) {
                                let moodPairs = [("🥀", "wind"), ("🌿", "leaf"), ("🌾", "sun.haze"), ("🌸", "leaf.rose"), ("🍂", "drop")]
                                ForEach(moodPairs, id: \.0) { emoji, symbol in
                                    Button(action: { selectedMoodEmoji = emoji }) {
                                        Image(systemName: symbol)
                                            .font(.system(size: 20, weight: .ultraLight))
                                            .foregroundColor(selectedMoodEmoji == emoji ? BloomTheme.driedRose : BloomTheme.textSecondary)
                                            .scaleEffect(selectedMoodEmoji == emoji ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMoodEmoji)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedMoodEmoji == emoji ? BloomTheme.driedRose.opacity(0.2) : Color.white.opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 24)
                }

                VStack(spacing: 12) {
                    Text("Sticker Tray")
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(botanicalStickers, id: \.0) { name, emoji in
                                Button(action: {
                                    let newSticker = Sticker(name: name)
                                    placedStickers.append(newSticker)
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 56, height: 56)
                                        .background(Color.white.opacity(0.6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 80)
                }
                .padding(.vertical, 12)
            }
        }
    }

    private func getEmojiForSticker(_ name: String) -> String {
        botanicalStickers.first(where: { $0.0 == name })?.1 ?? "🌸"
    }

    private func saveMemory() {
        guard !journalText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newMemory = Memory(
            image: processedImage,
            note: journalText,
            emoji: selectedMoodEmoji,
            date: Date(),
            stickers: placedStickers
        )

        memoryStore.addMemory(newMemory)
        memoryStore.saveMemories()

        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)

        dismiss()
    }
}

#Preview {
    CreateView()
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
}
