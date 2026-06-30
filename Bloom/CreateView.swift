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
    @Binding var storyText: String
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var processedImages: [Image] = []
    @State private var selectedMoodLabel: String = "Harika"
    @State private var placedStickers: [Sticker] = []
    @State private var selectedTextColor: Color = .black
    @Environment(\.colorScheme) var colorScheme

    let botanicalStickers = [
        ("daisy", "🌼"), ("rose", "🌹"), ("sunflower", "🌻"), ("tulip", "🌷"),
        ("hibiscus", "🌺"), ("cherry", "🌸"), ("bouquet", "💐"), ("leaf", "🌿"),
        ("autumn", "🍂"), ("coffee", "☕"), ("candle", "🕯️"), ("tea", "🫖"),
        ("camera", "📷"), ("laptop", "💻"), ("book", "📚"), ("headphones", "🎧"),
        ("heart", "🤎"), ("pink_heart", "🩷"), ("bow", "🎀"), ("lipstick", "💄"),
        ("handbag", "👜"), ("shoe", "👠"), ("dress", "👗"), ("airplane", "✈️"),
        ("luggage", "🧳"), ("butterfly", "🦋"), ("bee", "🐝"), ("star", "⭐"),
        ("sparkle", "✨"), ("moon", "🌙"), ("ribbon", "🎁")
    ]

    var body: some View {
        ZStack {
            BloomTheme.agedParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                // PREMIUM EDITORIAL TOP BAR
                HStack(alignment: .center, spacing: 0) {
                    // Left: Dismiss button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                    }
                    .frame(width: 44, height: 44)

                    // Center: Date
                    Spacer()
                    Text(formattedCurrentDate())
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                    Spacer()

                    // Right: Save button
                    Button(action: saveMemory) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(BloomTheme.driedRose)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BloomTheme.agedParchment)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // POLAROID CARD WITH PHOTO PICKER
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                            VStack(spacing: 0) {
                                // Photo area - Clickable for photo picker
                                PhotosPicker(selection: $selectedItems, matching: .images) {
                                    ZStack(alignment: .center) {
                                        if let image = processedImages.first {
                                            image.resizable().scaledToFill()
                                        } else {
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    BloomTheme.agedParchment,
                                                    BloomTheme.agedParchment.opacity(0.9)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )

                                            VStack(spacing: 8) {
                                                Image(systemName: "photo.artframe")
                                                    .font(.system(size: 40, weight: .light))
                                                    .foregroundColor(BloomTheme.textTertiary)
                                                Text("Fotoğraf Ekle")
                                                    .font(.system(size: 13, weight: .light, design: .serif))
                                                    .foregroundColor(BloomTheme.textSecondary)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 240)

                                // Text editor area
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Bugünün Öyküsü")
                                            .font(.system(size: 11, weight: .light, design: .serif))
                                            .foregroundColor(BloomTheme.textSecondary)
                                        Spacer()
                                        Text("\(storyText.count)/500")
                                            .font(.system(size: 10, weight: .light))
                                            .foregroundColor(storyText.count > 500 ? BloomTheme.driedRose : BloomTheme.textTertiary)
                                    }

                                    TextEditor(text: $storyText)
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .lineSpacing(2)
                                        .scrollContentBackground(.hidden)
                                        .background(BloomTheme.agedParchment.opacity(0.3))
                                        .cornerRadius(6)
                                        .frame(minHeight: 100)
                                }
                                .padding(12)
                            }
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)

                        // EDITORIAL TOOLBAR WITH ACTION BUTTONS
                        HStack(spacing: 12) {
                            // Font style button
                            Button(action: {}) {
                                Text("Aa")
                                    .font(.system(size: 14, weight: .light, design: .serif))
                                    .foregroundColor(BloomTheme.driedRose)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(BloomTheme.textSecondary.opacity(0.2), lineWidth: 1))
                            }

                            // Emotion/mood selector
                            Menu {
                                ForEach(["Harika", "İyi", "Orta", "Kötü", "Berbat"], id: \.self) { mood in
                                    Button(mood) {
                                        selectedMoodLabel = mood
                                    }
                                }
                            } label: {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(BloomTheme.textSecondary.opacity(0.2), lineWidth: 1))
                            }

                            // Additional photo button
                            Button(action: {}) {
                                Image(systemName: "photo")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(BloomTheme.textSecondary.opacity(0.2), lineWidth: 1))
                            }

                            // Pen/drawing tool
                            Button(action: {}) {
                                Image(systemName: "pencil.tip")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(BloomTheme.textSecondary.opacity(0.2), lineWidth: 1))
                            }

                            // Palette/color picker
                            Button(action: {}) {
                                Image(systemName: "palette")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(BloomTheme.textSecondary.opacity(0.2), lineWidth: 1))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // SCRAPBOOK STICKER STRIP
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Botanical Stickers")
                                .font(.system(size: 11, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)
                                .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(botanicalStickers, id: \.0) { sticker in
                                        Button(action: {
                                            placedStickers.append(Sticker(name: sticker.0))
                                        }) {
                                            Text(sticker.1)
                                                .font(.system(size: 24))
                                                .frame(width: 44, height: 44)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(BloomTheme.textSecondary.opacity(0.15), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        Spacer().frame(height: 8)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            if processedImages.isEmpty, let selectedImage = createViewState.processedImage {
                processedImages = [selectedImage]
            }
        }
        .onChange(of: selectedItems) {
            Task {
                var images: [Image] = []
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        images.append(Image(uiImage: uiImage))
                    }
                }
                DispatchQueue.main.async {
                    processedImages = images
                    selectedItems = []
                    print("QA_LOG: CreateView - Photo picker loaded, storyText persists: '\(storyText)'")
                }
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

    private func saveMemory() {
        let finalText = storyText.trimmingCharacters(in: .whitespaces)
        guard !finalText.isEmpty else { return }

        let now = Date()
        let firstImage = processedImages.first
        print("QA_LOG: SaveMemory - Text: '\(finalText)' | Images: \(processedImages.count) | Stickers: \(placedStickers.count)")

        var newEntry = Memory(
            image: firstImage,
            note: finalText,
            emoji: labelToEmoji(selectedMoodLabel),
            date: now,
            stickers: placedStickers
        )
        newEntry.images = processedImages

        MemoryStore.shared.addEntry(newEntry)
        print("QA_LOG: Entry saved - Store contains \(MemoryStore.shared.memories.count) entries")

        DispatchQueue.main.async {
            print("QA_LOG: Clearing draft state and closing sheet")
            storyText = ""
            processedImages = []
            placedStickers = []
            selectedMoodLabel = "Harika"
            selectedTextColor = .black
            createViewState.processedImage = nil

            showCreateSheet = false
            selectedTab = 3
        }
    }

    private func labelToEmoji(_ label: String) -> String {
        switch label {
        case "Harika": return "🌸"
        case "İyi": return "✨"
        case "Orta": return "🌾"
        case "Kötü": return "🥀"
        case "Berbat": return "☁️"
        default: return "📝"
        }
    }
}

#Preview {
    CreateView(showCreateSheet: .constant(true), selectedTab: .constant(0), storyText: .constant(""))
        .environmentObject(LocalizationManager())
        .environmentObject(MemoryStore.shared)
        .environmentObject(CreateViewState())
}
