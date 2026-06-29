import SwiftUI
import Combine

struct MemoryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var memoryStore: MemoryStore
    @EnvironmentObject var localization: LocalizationManager
    @State var memory: Memory
    @State private var editingNote = ""
    @Namespace private var animationNamespace

    let botanicalMap = ["dried_daisy": "🌼", "mini_heart": "🤎", "vintage_seal": "🪞", "candlelight": "✨"]

    var body: some View {
        ZStack {
            BloomTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { saveAndDismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(BloomTheme.driedRose)
                    }
                    Spacer()
                    Text(formattedDate(memory.date))
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundColor(BloomTheme.textSecondary)
                }
                .padding(20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(BloomTheme.agedParchment)
                                .frame(maxWidth: 280, maxHeight: 360)
                                .offset(x: 3, y: 4)

                            VStack(spacing: 0) {
                                ZStack {
                                    LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    if let image = memory.image {
                                        image.resizable().scaledToFill()
                                    }
                                }
                                .frame(height: 240)
                                .cornerRadius(8)
                                .padding(12)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(memory.note.prefix(80) + (memory.note.count > 80 ? "..." : ""))
                                        .font(.system(size: 12, weight: .light))
                                        .lineSpacing(2)
                                        .foregroundColor(BloomTheme.textPrimary)
                                        .lineLimit(2)

                                    Text(memory.emoji)
                                        .font(.system(size: 24))
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.clear)

                                ForEach($memory.stickers) { $sticker in
                                    buildStickerView($sticker)
                                }
                            }
                            .frame(maxWidth: 280, maxHeight: 360)
                            .matchedGeometryEffect(id: memory.id, in: animationNamespace)
                        }
                        .frame(width: 280, height: 360)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notlar")
                                .font(.system(size: 12, weight: .light, design: .serif))
                                .foregroundColor(BloomTheme.textSecondary)

                            TextEditor(text: $editingNote)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(BloomTheme.textPrimary)
                                .frame(height: 100)
                                .padding(12)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(BloomTheme.textTertiary.opacity(0.2), lineWidth: 0.5))
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
                            ForEach(["dried_daisy", "mini_heart", "vintage_seal", "candlelight"], id: \.self) { stickerName in
                                Button(action: {
                                    let newSticker = Sticker(name: stickerName)
                                    memory.stickers.append(newSticker)
                                    print("QA_LOG: MemoryDetailView - Added sticker: \(stickerName)")
                                }) {
                                    Text(botanicalMap[stickerName] ?? stickerName)
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
                .background(Color.white.opacity(0.3))
            }
        }
        .onAppear {
            editingNote = memory.note
        }
    }

    @ViewBuilder
    private func buildStickerView(_ sticker: Binding<Sticker>) -> some View {
        MemoryDetailStickerView(sticker: sticker.wrappedValue)
            .offset(x: sticker.offsetX.wrappedValue, y: sticker.offsetY.wrappedValue)
            .scaleEffect(sticker.scale.wrappedValue)
            .rotationEffect(.degrees(sticker.rotation.wrappedValue))
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            sticker.offsetX.wrappedValue = value.translation.width
                            sticker.offsetY.wrappedValue = value.translation.height
                        },
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                sticker.scale.wrappedValue = value
                            },
                        RotationGesture()
                            .onChanged { value in
                                sticker.rotation.wrappedValue = value.degrees
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
            print("QA_LOG: MemoryDetailView - Saved memory with \(memory.stickers.count) stickers")
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "dd.MM.yyyy" : "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct MemoryDetailStickerView: View {
    let sticker: Sticker
    let stickerMap = ["dried_daisy": "🌼", "mini_heart": "🤎", "vintage_seal": "🪞", "candlelight": "✨"]

    var body: some View {
        Text(stickerMap[sticker.name] ?? sticker.name)
            .font(.system(size: 28))
            .opacity(0.75)
    }
}

#Preview {
    let testMemory = Memory(image: nil, note: "Test memory", emoji: "🌸", stickers: [])
    MemoryDetailView(memory: testMemory)
        .environmentObject(MemoryStore.shared)
        .environmentObject(LocalizationManager())
}
