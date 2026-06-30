import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.colorScheme) var colorScheme

    let menuItems = [
        (icon: "checkmark.square", label: "Dijital Günlük", tab: 0),
        (icon: "photo.fill", label: "Fotoğraflar", tab: 1),
        (icon: "sparkles", label: "Stickerlar", tab: 2),
        (icon: "character.textbox", label: "Yazılar", tab: 3),
        (icon: "calendar.circle", label: "Takvim Yaprakları", tab: 4),
        (icon: "book.fill", label: "Kitap Şeklinde Anılar", tab: 5)
    ]

    var body: some View {
        ZStack {
            BloomTheme.adaptiveBackground(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Logo section
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text("🌸")
                            .font(.system(size: 28))
                        Text("Bloom")
                            .font(.system(size: 24, weight: .light, design: .serif))
                            .tracking(0.8)
                            .foregroundColor(BloomTheme.textPrimary)
                    }

                    Text("Your story,\nYour book.")
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .tracking(0.3)
                        .foregroundColor(BloomTheme.textSecondary)
                        .lineSpacing(2)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)

                Divider()
                    .foregroundColor(BloomTheme.textTertiary.opacity(0.2))
                    .padding(.vertical, 16)

                // Menu items
                VStack(spacing: 0) {
                    ForEach(0..<menuItems.count, id: \.self) { index in
                        let item = menuItems[index]
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(BloomTheme.driedRose.opacity(selectedTab == index ? 1.0 : 0.6))
                                    .frame(width: 20)

                                Text(item.label)
                                    .font(.system(size: 12, weight: .light, design: .serif))
                                    .foregroundColor(BloomTheme.textPrimary.opacity(selectedTab == index ? 1.0 : 0.7))

                                Spacer()

                                if selectedTab == index {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(BloomTheme.driedRose)
                                        .frame(width: 3, height: 16)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(BloomTheme.driedRose.opacity(selectedTab == index ? 0.08 : 0.0))
                            )
                        }
                        .padding(.horizontal, 8)

                        if index < menuItems.count - 1 {
                            Divider()
                                .foregroundColor(BloomTheme.textTertiary.opacity(0.1))
                                .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.vertical, 8)

                Spacer()

                // Bottom quote
                VStack(spacing: 0) {
                    Divider()
                        .foregroundColor(BloomTheme.textTertiary.opacity(0.2))
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        Text("Anların güzelleştir, kişisel kitabını oluştur.")
                            .font(.system(size: 11, weight: .light, design: .serif))
                            .italic()
                            .lineSpacing(1.5)
                            .foregroundColor(BloomTheme.textSecondary)
                            .multilineTextAlignment(.center)

                        Text("💚")
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: 220)
    }
}

#Preview {
    SidebarView(selectedTab: .constant(0))
        .environmentObject(LocalizationManager())
}
