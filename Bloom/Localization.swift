import SwiftUI
import Combine

enum Language: String, CaseIterable {
    case turkish = "tr"
    case english = "en"

    var displayName: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .turkish

    func string(_ key: String) -> String {
        switch currentLanguage {
        case .turkish:
            return turkishStrings[key] ?? key
        case .english:
            return englishStrings[key] ?? key
        }
    }

    private let turkishStrings: [String: String] = [
        "bloom_title": "Bloom",
        "anasayfa": "Anasayfa",
        "istatistikler": "İstatistikler",
        "yeni_ani": "Yeni Anı",
        "takvim": "Takvim",
        "profil": "Profil",
        "ani": "Anı",
        "date": "28 Haziran 2026",
        "stats_title": "İstatistikler",
        "mood_tracking": "Ruh Hali Takibi",
        "mood_desc": "Ruh hali istatistikleri ve analitiği için yer tutucu.",
        "create_title": "Yeni Anı",
        "create_desc": "Yeni anı oluştur",
        "diary_title": "Bugün'ün Öyküsü",
        "diary_placeholder": "Bugün harika bir gün! Kendime zaman ayırmak bana çok iyi geldi...",
        "add_photo": "Fotoğraf Ekle",
        "calendar_title": "Takvim",
        "memory_timeline": "Anı Zaman Çizelgesi",
        "calendar_desc": "Anı takvimi ve zaman çizelgesi görünümü için yer tutucu.",
        "profile_title": "Profil",
        "user_settings": "Kullanıcı Ayarları",
        "profile_desc": "Kullanıcı profili ve ayarları için yer tutucu.",
        "language": "Dil",
    ]

    private let englishStrings: [String: String] = [
        "bloom_title": "Bloom",
        "anasayfa": "Home",
        "istatistikler": "Stats",
        "yeni_ani": "Create",
        "takvim": "Calendar",
        "profil": "Profile",
        "ani": "Memory",
        "date": "June 28, 2026",
        "stats_title": "Statistics",
        "mood_tracking": "Mood Tracking",
        "mood_desc": "Placeholder for mood statistics and analytics.",
        "create_title": "Create Memory",
        "create_desc": "Create a new memory",
        "diary_title": "Today's Story",
        "diary_placeholder": "Had an amazing day! Taking time for myself has been wonderful...",
        "add_photo": "Add Photo",
        "calendar_title": "Calendar",
        "memory_timeline": "Memory Timeline",
        "calendar_desc": "Placeholder for memory calendar and timeline view.",
        "profile_title": "Profile",
        "user_settings": "User Settings",
        "profile_desc": "Placeholder for user profile and settings.",
        "language": "Language",
    ]
}
