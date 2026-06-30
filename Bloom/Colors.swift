import SwiftUI

struct BloomTheme {
    // Dried Flower Botanical Palette (Light Mode)
    static let driedRose = Color(red: 0.65, green: 0.45, blue: 0.50)
    static let sageGreen = Color(red: 0.55, green: 0.62, blue: 0.55)
    static let agedParchment = Color(red: 0.96, green: 0.94, blue: 0.91)
    static let siennaDust = Color(red: 0.78, green: 0.68, blue: 0.52)

    // Semantic Colors - Light Mode
    static let background = agedParchment
    static let cardBackground = Color.white.opacity(0.95)
    static let textPrimary = Color.black.opacity(0.8)
    static let textSecondary = Color.black.opacity(0.5)
    static let textTertiary = Color.black.opacity(0.3)
    static let accent = driedRose
    static let accentLight = driedRose.opacity(0.3)

    // Dark Mode Colors
    static func backgroundDark() -> Color {
        Color(red: 0.12, green: 0.12, blue: 0.12)
    }

    static func cardBackgroundDark() -> Color {
        Color(red: 0.18, green: 0.18, blue: 0.18)
    }

    static func textPrimaryDark() -> Color {
        Color.white.opacity(0.9)
    }

    static func textSecondaryDark() -> Color {
        Color.white.opacity(0.6)
    }

    static func textTertiaryDark() -> Color {
        Color.white.opacity(0.4)
    }

    // Adaptive color helper
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? backgroundDark() : background
    }

    static func adaptiveCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? cardBackgroundDark() : cardBackground
    }

    static func adaptiveTextPrimary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textPrimaryDark() : textPrimary
    }

    static func adaptiveTextSecondary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textSecondaryDark() : textSecondary
    }

    static func adaptiveTextTertiary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textTertiaryDark() : textTertiary
    }
}
