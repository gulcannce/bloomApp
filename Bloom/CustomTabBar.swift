import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCreateSheet: Bool

    let tabItems = [
        (icon: "house.fill", tag: 0),
        (icon: "chart.bar.fill", tag: 1),
        (icon: "star.fill", tag: 2),
        (icon: "calendar", tag: 3),
        (icon: "person.fill", tag: 4)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(BloomTheme.textTertiary.opacity(0.2))

            HStack(spacing: 0) {
                // Left side - 2 items (Home, Stats)
                ForEach(0..<2, id: \.self) { index in
                    Button(action: { selectedTab = index }) {
                        Image(systemName: tabItems[index].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(selectedTab == index ? BloomTheme.driedRose : BloomTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Center - Plus Button (resized to match surrounding icons)
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(BloomTheme.driedRose)
                }
                .frame(maxWidth: .infinity)

                // Right side - 2 items (Achievements, Calendar, Profile - 3 items squeezed)
                ForEach(2..<5, id: \.self) { index in
                    Button(action: { selectedTab = index }) {
                        Image(systemName: tabItems[index].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(selectedTab == index ? BloomTheme.driedRose : BloomTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(BloomTheme.agedParchment)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0), showCreateSheet: .constant(false))
}
