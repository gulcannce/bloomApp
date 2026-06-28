import SwiftUI

struct ContentView: View {
    // Core states for multiple images
    let images = ["flower_placeholder", "leaf_placeholder", "heart_placeholder"] // Sample array
    @State private var currentIndex = 0

    // Independent gesture states for the active image
    @State private var photoScale: CGFloat = 1.0
    @State private var photoOffset: CGSize = .zero
    @State private var photoRotation: Angle = .zero
    @State private var selectedEmoji: String? = nil

    var body: some View {
        ZStack {
            // Soft cream/pastel editorial background
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Bloom")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                // NATIVE MINI EMOJI SELECTION BAR (Pinterest Vibe)
                HStack(spacing: 24) {
                    ForEach(["🌸", "✨", "☁️", "🌱", "🤍"], id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            print("QA_LOG: Native Emoji Selected -> \(emoji)")
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
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())

                // STATIC POLAROID CARD CONTAINER (KISS Rule)
                VStack(spacing: 0) {

                    // 1. EXTENDED MULTI-IMAGE CAROUSEL AREA (Stretches perfectly down to text)
                    TabView(selection: $currentIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ZStack {
                                Color(red: 0.92, green: 0.92, blue: 0.92) // Elegant gray window

                                Image(systemName: "photo.artframe") // Temporary native icon
                                    .font(.system(size: 40))
                                    .foregroundColor(.black.opacity(0.2))
                            }
                            // Apply transformations STRICTLY to inner content
                            .scaleEffect(currentIndex == index ? photoScale : 1.0)
                            .offset(currentIndex == index ? photoOffset : .zero)
                            .rotationEffect(currentIndex == index ? photoRotation : .zero)
                            .highPriorityGesture(
                                DragGesture()
                                    .onChanged { value in
                                        photoOffset = value.translation
                                        print("QA_LOG: Photo Offset -> \(photoOffset)")
                                    }
                                    .onEnded { _ in }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page) // Pure seamless swipe
                    .frame(width: 290, height: 310) // PERFECTLY EXTENDED DOWNWARD
                    .cornerRadius(4)
                    .clipped() // FINAL GATEKEEPER: Locks everything inside the photo window!
                    .padding(.top, 15)

                    Spacer()

                    // 2. EDITORIAL TEXT BLOCK (Pinned perfectly at the wide bottom area)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Anı")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.black.opacity(0.7))
                        Text("28 Haziran 2026")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24) // Traditional Polaroid frame wide bottom margin
                }
                .frame(width: 320, height: 420) // THE ANCHORED STATIC CONTAINER
                .background(Color.white) // Clean luxury white card texture
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)

                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    ContentView()
}
