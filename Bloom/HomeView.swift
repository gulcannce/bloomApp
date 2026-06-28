import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var memoryStore = MemoryStore.shared
    @State private var currentIndex = 0
    @State private var photoScale: CGFloat = 1.0
    @State private var photoOffset: CGSize = .zero
    @State private var photoRotation: Angle = .zero
    @State private var selectedEmoji: String? = nil
    @State private var expandedMemoryId: UUID? = nil
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Text(localization.string("bloom_title"))
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(BloomTheme.textPrimary)

                    Spacer()

                    Menu {
                        ForEach(Language.allCases, id: \.self) { language in
                            Button(action: {
                                localization.currentLanguage = language
                            }) {
                                HStack {
                                    Text(language.displayName)
                                    if localization.currentLanguage == language {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundColor(BloomTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 20)

                HStack(spacing: 24) {
                    ForEach(["🌸", "✨", "☁️", "🌱", "🤍"], id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                        }) {
                            Text(emoji)
                                .font(.system(size: 26))
                                .scaleEffect(selectedEmoji == emoji ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedEmoji)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.5))
                .clipShape(Capsule())

                VStack(spacing: 0) {
                    if memoryStore.memories.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.black.opacity(0.2))
                            Text(localization.currentLanguage == .turkish ? "Henüz anı yok" : "No memories yet")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .frame(height: 310)
                    } else {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(BloomTheme.agedParchment)
                                .frame(width: 290, height: 310)
                                .offset(x: 4, y: 6)
                                .rotationEffect(.degrees(-2.5), anchor: .center)

                            VStack(spacing: 0) {
                                TabView(selection: $currentIndex) {
                                    ForEach(memoryStore.memories.indices, id: \.self) { index in
                                        let memory = memoryStore.memories[index]
                                        ZStack {
                                            LinearGradient(gradient: Gradient(colors: [BloomTheme.agedParchment, BloomTheme.agedParchment.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            if let image = memory.image {
                                                image.resizable().scaledToFill()
                                            } else {
                                                Image(systemName: "photo.artframe")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(BloomTheme.textTertiary)
                                            }
                                        }
                                        .scaleEffect(currentIndex == index ? photoScale : 1.0)
                                        .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0), value: photoScale)
                                        .offset(currentIndex == index ? photoOffset : .zero)
                                        .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0), value: photoOffset)
                                        .rotationEffect(currentIndex == index ? photoRotation : .zero)
                                        .animation(.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0), value: photoRotation)
                                        .highPriorityGesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    photoOffset = value.translation
                                                }
                                                .onEnded { _ in }
                                        )
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(.page)
                                .frame(width: 290, height: 310)
                                .cornerRadius(4)
                                .clipped()
                            }
                            .background(BloomTheme.cardBackground)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)

                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 60, height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                                .offset(y: 8)
                                .rotationEffect(.degrees(2.0), anchor: .center)
                        }
                        .frame(width: 320, height: 420)
                        .padding(.top, 15)
                    }

                    Spacer()

                    if memoryStore.memories.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(localization.currentLanguage == .turkish ? "İlk anını oluştur" : "Create your first memory")
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundColor(BloomTheme.driedRose)
                            Text(localization.currentLanguage == .turkish ? "Create sekmesine git" : "Go to Create tab")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(BloomTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    } else {
                        let current = memoryStore.memories[currentIndex]
                        VStack(alignment: .leading, spacing: 6) {
                            Text(current.note.prefix(50) + (current.note.count > 50 ? "..." : ""))
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(BloomTheme.textPrimary)
                            Text(formattedDate(current.date))
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(BloomTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                .frame(width: 320, height: 420)
                .background(BloomTheme.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
                .onTapGesture {
                    if !memoryStore.memories.isEmpty {
                        withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) {
                            expandedMemoryId = memoryStore.memories[currentIndex].id
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, 40)

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

                        ScrollView {
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

                                        if !expandedMemory.stickers.isEmpty {
                                            HStack(spacing: 8) {
                                                ForEach(expandedMemory.stickers, id: \.self) { sticker in
                                                    Text(sticker)
                                                        .font(.system(size: 20))
                                                        .opacity(0.7)
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
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
                    }
                    .background(BloomTheme.cardBackground)
                    .cornerRadius(20)
                    .padding(16)
                    .frame(maxHeight: 600)
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .turkish ? "dd.MM.yyyy" : "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}
