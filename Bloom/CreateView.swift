import SwiftUI
import PhotosUI
import UIKit

struct CreateView: View {
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var createViewState: CreateViewState
    @Environment(\.dismiss) var dismiss
    @Binding var showCreateSheet: Bool

    @State private var journalText: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var selectedMoodLabel: String = "Harika"
    @State private var placedStickers: [Sticker] = []

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
        .onAppear {
            if processedImage == nil, let selectedImage = createViewState.processedImage {
                processedImage = selectedImage
            }
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

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        todayComponents.year = 2026
        todayComponents.month = 6
        todayComponents.day = 29
        let lockedDate = calendar.date(from: todayComponents) ?? Date()

        print("QA_LOG: SaveMemory - Text captured: '\(safeNote)' | Mood: '\(selectedMoodLabel)' | Image present: \(processedImage != nil) | Stickers: \(placedStickers.count) | Locked date: \(lockedDate)")

        let newEntry = Memory(
            image: processedImage,
            note: safeNote,
            emoji: labelToEmoji(selectedMoodLabel),
            date: lockedDate,
            stickers: placedStickers
        )

        MemoryStore.shared.addEntry(newEntry)

        print("QA_LOG: Entry persisted - Store now contains \(MemoryStore.shared.memories.count) entries")

        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)

        DispatchQueue.main.async {
            print("QA_LOG: Explicitly toggling showCreateSheet = false to trigger parent re-render")
            showCreateSheet = false
            print("QA_LOG: Parent ContentView binding updated - HomeView and CalendarView will refresh")
        }
    }
}

#Preview {
    CreateView(showCreateSheet: .constant(true))
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
        .environmentObject(CreateViewState())
}
