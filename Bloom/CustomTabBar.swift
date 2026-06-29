import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCreateSheet: Bool

    let tabItems = [
        (icon: "house.fill", tag: 0, color: Color(red: 0.72, green: 0.55, blue: 0.50)),        // Soft Terracotta
        (icon: "chart.bar.fill", tag: 1, color: BloomTheme.sageGreen),                          // SageGreen
        (icon: "star.fill", tag: 2, color: Color(red: 0.82, green: 0.75, blue: 0.55)),         // Soft Muted Gold
        (icon: "calendar", tag: 3, color: Color(red: 0.68, green: 0.60, blue: 0.50)),          // Muted Cocoa
        (icon: "person.fill", tag: 4, color: Color(red: 0.70, green: 0.65, blue: 0.60))        // Soft Taupe
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(BloomTheme.textTertiary.opacity(0.2))

            HStack(spacing: 0) {
                // Left side - 2 items (Home, Stats)
                ForEach(0..<2, id: \.self) { index in
                    VStack(spacing: 4) {
                        Button(action: { selectedTab = index }) {
                            Image(systemName: tabItems[index].icon)
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(tabItems[index].color.opacity(selectedTab == index ? 1.0 : 0.6))
                        }

                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(tabItems[index].color)
                                .frame(width: 16, height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Center - Plus Button (bolded and colorized)
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BloomTheme.driedRose)
                }
                .frame(maxWidth: .infinity)

                // Right side - 2 items (Achievements, Calendar, Profile - 3 items squeezed)
                ForEach(2..<5, id: \.self) { index in
                    VStack(spacing: 4) {
                        Button(action: { selectedTab = index }) {
                            Image(systemName: tabItems[index].icon)
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(tabItems[index].color.opacity(selectedTab == index ? 1.0 : 0.6))
                        }

                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(tabItems[index].color)
                                .frame(width: 16, height: 3)
                        }
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
