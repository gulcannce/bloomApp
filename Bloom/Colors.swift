import SwiftUI

struct BloomTheme {
    // Dried Flower Botanical Palette
    static let driedRose = Color(red: 0.65, green: 0.45, blue: 0.50)
    static let sageGreen = Color(red: 0.55, green: 0.62, blue: 0.55)
    static let agedParchment = Color(red: 0.96, green: 0.94, blue: 0.91)
    static let siennaDust = Color(red: 0.78, green: 0.68, blue: 0.52)

    // Semantic Colors
    static let background = agedParchment
    static let cardBackground = Color.white.opacity(0.95)
    static let textPrimary = Color.black.opacity(0.8)
    static let textSecondary = Color.black.opacity(0.5)
    static let textTertiary = Color.black.opacity(0.3)
    static let accent = driedRose
    static let accentLight = driedRose.opacity(0.3)
}
