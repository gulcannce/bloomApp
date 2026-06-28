import SwiftUI
import PhotosUI
import UIKit

struct CreateView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
    @State private var diaryText: String = ""
    @FocusState private var isTextFocused: Bool
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var processedImage: Image? = nil
    @State private var savedSuccessfully = false
    @State private var selectedMoodEmoji: String = "🌸"

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(formattedDate())
                                .font(.system(size: 18, weight: .light, design: .serif))
                                .tracking(0.5)
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.top, 24)

                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.98, green: 0.97, blue: 0.96))
                                .offset(x: 4, y: 6)
                                .rotationEffect(.degrees(-2.5), anchor: .center)

                            VStack(spacing: 16) {
                                CreatePhotoView(image: processedImage)
                                    .frame(height: 260)
                                    .overlay(alignment: .topLeading) {
                                        Text("📌")
                                            .font(.system(size: 20))
                                            .offset(x: -12, y: -12)
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Text("📌")
                                            .font(.system(size: 20))
                                            .offset(x: 12, y: -12)
                                    }

                                HStack(spacing: 200) {
                                    Text("🌸")
                                        .font(.system(size: 16))
                                    Text("🌼")
                                        .font(.system(size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.white.opacity(0.55))
                                .frame(width: 60, height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                                .offset(y: 8)
                                .rotationEffect(.degrees(2.0), anchor: .center)
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bugün'ün Öyküsü")
                                .font(.system(size: 14, weight: .light, design: .serif))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.horizontal, 16)

                            TextEditor(text: $diaryText)
                                .font(.system(size: 16, weight: .light, design: .default))
                                .lineSpacing(4)
                                .padding(12)
                                .frame(minHeight: 140)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                                .focused($isTextFocused)
                        }
                        .padding(.vertical, 16)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(localization.currentLanguage == .turkish ? "Bugünün Hali" : "Today's Mood")
                                .font(.system(size: 14, weight: .light, design: .serif))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(.horizontal, 16)

                            HStack(spacing: 12) {
                                ForEach(["🌸", "✨", "☁️", "🌱", "🤍"], id: \.self) { emoji in
                                    Button(action: {
                                        selectedMoodEmoji = emoji
                                        triggerEmojiHaptic()
                                        print("QA_LOG: Mood Emoji Selected -> \(emoji)")
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 24))
                                            .scaleEffect(selectedMoodEmoji == emoji ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMoodEmoji)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedMoodEmoji == emoji ? Color.white.opacity(0.8) : Color.white.opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.bottom, 80)
                }

                Spacer()

                HStack(spacing: 16) {
                    ToolbarButton(icon: "textformat.size", label: "Aa")

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ToolbarButton(icon: "photo.stack", label: "📷")
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                processedImage = Image(uiImage: uiImage)
                                print("QA_LOG: Photo Selected and Loaded")
                            }
                        }
                    }

                    ToolbarButton(icon: "scribble", label: "✏️")

                    Spacer()

                    Button(action: saveMemory) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text(localization.currentLanguage == .turkish ? "Kaydet" : "Save")
                                .font(.system(size: 12, weight: .light))
                        }
                        .padding(8)
                        .padding(.horizontal, 4)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(6)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .padding(8)
            }
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = localization.currentLanguage == .turkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    private func triggerEmojiHaptic() {
        let lightHaptic = UIImpactFeedbackGenerator(style: .light)
        lightHaptic.impactOccurred()
    }

    private func saveMemory() {
        guard !diaryText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("QA_LOG: Memory save cancelled - empty note")
            return
        }
        let newMemory = Memory(image: processedImage, note: diaryText, emoji: selectedMoodEmoji)
        memoryStore.addMemory(newMemory)
        print("QA_LOG: Memory saved - \(newMemory.id)")

        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)

        diaryText = ""
        processedImage = nil
        savedSuccessfully = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            savedSuccessfully = false
        }
    }
}

struct CreatePhotoView: View {
    let image: Image?

    var body: some View {
        ZStack {
            Color(red: 0.92, green: 0.92, blue: 0.92)

            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.black.opacity(0.2))

                    Text("Fotoğraf Ekle")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black.opacity(0.3))
                }
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ToolbarButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button(action: {
            print("QA_LOG: Toolbar Action Triggered -> \(label)")
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.black.opacity(0.6))

                Text(label)
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
