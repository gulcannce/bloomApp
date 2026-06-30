import SwiftUI
import PhotosUI
import UIKit

struct CreateView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var createViewState: CreateViewState
    @Environment(\.dismiss) var dismiss
    @Binding var showCreateSheet: Bool
    @Binding var selectedTab: Int

    @State private var journalText: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var processedImages: [Image] = []
    @State private var selectedMoodLabel: String = "Harika"
    @State private var placedStickers: [Sticker] = []
    @Environment(\.colorScheme) var colorScheme

    let botanicalStickers = [
        ("daisy", "🌼"),
        ("rose", "🌹"),
        ("sunflower", "🌻"),
        ("tulip", "🌷"),
        ("hibiscus", "🌺"),
        ("cherry", "🌸"),
        ("bouquet", "💐"),
        ("leaf", "🌿"),
        ("autumn", "🍂"),
        ("heart", "🤎"),
        ("butterfly", "🦋"),
        ("bee", "🐝"),
        ("star", "⭐"),
        ("sparkle", "✨"),
        ("moon", "🌙"),
        ("ribbon", "🎀"),
        ("fox", "🦊"),
        ("love_letter", "💌")
    ]

    var body: some View {
        ZStack {
            BloomTheme.adaptiveBackground(colorScheme).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                    }
                    Spacer()
                    Button(action: saveMemory) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .light))
                            Text("Kaydet")
                                .font(.system(size: 14, weight: .light, design: .serif))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(BloomTheme.driedRose)
                        .cornerRadius(8)
                    }
                }
                .padding(20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Date display
                        Text(formattedCurrentDate())
                            .font(.system(size: 13, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)

                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                            VStack(spacing: 0) {
                                ZStack(alignment: .center) {
                                    LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)

                                    if let image = processedImages.first {
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

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Bugün'ün Öyküsü")
                                            .font(.system(size: 11, weight: .light, design: .serif))
                                            .foregroundColor(BloomTheme.textSecondary)
                                        Spacer()
                                        Text("\(journalText.count)/500")
                                            .font(.system(size: 10, weight: .light))
                                            .foregroundColor(journalText.count > 500 ? BloomTheme.driedRose : BloomTheme.textTertiary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.top, 8)

                                    TextEditor(text: $journalText)
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .lineSpacing(3)
                                        .foregroundColor(BloomTheme.textPrimary)
                                        .scrollContentBackground(.hidden)
                                        .background(BloomTheme.agedParchment.opacity(0.3))
                                        .cornerRadius(6)
                                        .frame(minHeight: 100)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 12)

                                    // Formatting toolbar
                                    HStack(spacing: 12) {
                                        Button(action: {}) {
                                            Image(systemName: "textformat")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "smiley")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        Button(action: {}) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(BloomTheme.textSecondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 8)
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

                            VStack(spacing: 12) {
                                HStack(spacing: 10) {
                                    let moods = [
                                        ("Harika", Color(red: 0.85, green: 0.75, blue: 0.80)),
                                        ("İyi", Color(red: 0.80, green: 0.85, blue: 0.78)),
                                        ("Orta", Color(red: 0.88, green: 0.82, blue: 0.70)),
                                        ("Kötü", Color(red: 0.83, green: 0.72, blue: 0.75)),
                                        ("Berbat", Color(red: 0.78, green: 0.68, blue: 0.55))
                                    ]
                                    ForEach(moods, id: \.0) { label, color in
                                        Button(action: { selectedMoodLabel = label }) {
                                            VStack(spacing: 4) {
                                                MoodDoodleFace(mood: label, size: 36)
                                                    .frame(width: 36, height: 36)
                                                    .background(Circle().fill(selectedMoodLabel == label ? color.opacity(0.9) : color))
                                                    .scaleEffect(selectedMoodLabel == label ? 1.1 : 1.0)
                                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMoodLabel)

                                                Text(label)
                                                    .font(.system(size: 9, weight: .light, design: .serif))
                                                    .foregroundColor(BloomTheme.textSecondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 24)
                }

                VStack(spacing: 12) {
                    Text("Çıkartmalar")
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                        .tracking(0.4)
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
        .onAppear {
            if processedImages.isEmpty, let selectedImage = createViewState.processedImage {
                processedImages = [selectedImage]
            }
        }
    }

    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        if localization.currentLanguage == .turkish {
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: Date()).capitalized
        } else {
            formatter.dateFormat = "MMMM dd, yyyy"
            return formatter.string(from: Date())
        }
    }

    private func getEmojiForSticker(_ name: String) -> String {
        botanicalStickers.first(where: { $0.0 == name })?.1 ?? "🌸"
    }

    private func labelToEmoji(_ label: String) -> String {
        switch label {
        case "Harika": return "🥀"
        case "İyi": return "🌿"
        case "Orta": return "🌾"
        case "Kötü": return "🌸"
        case "Berbat": return "🍂"
        default: return "🌸"
        }
    }

    private func saveMemory() {
        let finalText = journalText.trimmingCharacters(in: .whitespaces)
        let safeNote = finalText.isEmpty ? "Günün hali" : finalText

        let now = Date()
        let firstImage = processedImages.first
        print("QA_LOG: SaveMemory - Text: '\(safeNote)' | Mood: '\(selectedMoodLabel)' | Images: \(processedImages.count) | Stickers: \(placedStickers.count) | Date: \(now)")

        var newEntry = Memory(
            image: firstImage,
            note: safeNote,
            emoji: labelToEmoji(selectedMoodLabel),
            date: now,
            stickers: placedStickers
        )
        newEntry.images = processedImages

        MemoryStore.shared.addEntry(newEntry)

        print("QA_LOG: Entry persisted - Store now contains \(MemoryStore.shared.memories.count) entries")

        // Haptic feedback
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        print("QA_LOG: Success haptic triggered")

        DispatchQueue.main.async {
            print("QA_LOG: Resetting temporary picker states for next session")
            journalText = ""
            processedImages = []
            placedStickers = []
            selectedMoodLabel = "Harika"
            createViewState.processedImage = nil

            print("QA_LOG: Explicitly toggling showCreateSheet = false to trigger parent re-render")
            showCreateSheet = false
            print("QA_LOG: Navigating to Calendar tab (selectedTab = 3)")
            selectedTab = 3
            print("QA_LOG: Parent ContentView binding updated - HomeView and CalendarView will refresh")
        }
    }
}

#Preview {
    CreateView(showCreateSheet: .constant(true), selectedTab: .constant(0))
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
        .environmentObject(CreateViewState())
}
