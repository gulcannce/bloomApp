import SwiftUI
import Combine

// MARK: - Localization
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

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var localization = LocalizationManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.string("anasayfa"), systemImage: "house.fill")
                }
                .tag(0)

            StatsView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.string("istatistikler"), systemImage: "chart.bar.fill")
                }
                .tag(1)

            CreateView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.string("yeni_ani"), systemImage: "plus.circle.fill")
                }
                .tag(2)

            CalendarView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.string("takvim"), systemImage: "calendar")
                }
                .tag(3)

            ProfileView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.string("profil"), systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.black.opacity(0.7))
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var localization: LocalizationManager
    let images = ["flower_placeholder", "leaf_placeholder", "heart_placeholder"]
    @State private var currentIndex = 0
    @State private var photoScale: CGFloat = 1.0
    @State private var photoOffset: CGSize = .zero
    @State private var photoRotation: Angle = .zero
    @State private var selectedEmoji: String? = nil

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Text(localization.string("bloom_title"))
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .tracking(1.0)
                        .foregroundColor(.black.opacity(0.8))

                    Spacer()

                    Menu {
                        ForEach(Language.allCases, id: \.self) { language in
                            Button(action: {
                                localization.currentLanguage = language
                                print("QA_LOG: Language Changed -> \(language.displayName)")
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
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)

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

                VStack(spacing: 0) {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ZStack {
                                Color(red: 0.92, green: 0.92, blue: 0.92)
                                Image(systemName: "photo.artframe")
                                    .font(.system(size: 40))
                                    .foregroundColor(.black.opacity(0.2))
                            }
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
                    .tabViewStyle(.page)
                    .frame(width: 290, height: 310)
                    .cornerRadius(4)
                    .clipped()
                    .padding(.top, 15)

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.string("ani"))
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.black.opacity(0.7))
                        Text(localization.string("date"))
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .frame(width: 320, height: 420)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)

                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

// MARK: - Stats View
struct StatsView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(localization.string("stats_title"))
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.string("mood_tracking"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text(localization.string("mood_desc"))
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Create View (Scrapbook Diary)
struct CreateView: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var diaryText: String = ""
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Date Header
                        VStack(spacing: 8) {
                            Text(formattedDate())
                                .font(.system(size: 18, weight: .light, design: .serif))
                                .tracking(0.5)
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.top, 24)

                        // Scrapbook Card with Polaroid
                        VStack(spacing: 16) {
                            // Decorative tape corners (visual placeholders)
                            CreatePhotoView()
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

                            // Decorative flowers
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
                        .padding(.horizontal, 16)

                        // Diary Text Editor
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
                    }
                    .padding(.bottom, 80)
                }

                Spacer()

                // Bottom Toolbar (5 Actions)
                HStack(spacing: 16) {
                    ToolbarButton(icon: "textformat.size", label: "Aa")
                    ToolbarButton(icon: "smiley", label: "😊")
                    ToolbarButton(icon: "photo.stack", label: "📷")
                    ToolbarButton(icon: "scribble", label: "✏️")
                    ToolbarButton(icon: "square.grid.2x2", label: "■■")

                    Spacer()
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
}

// MARK: - Create Photo View
struct CreatePhotoView: View {
    var body: some View {
        ZStack {
            Color(red: 0.92, green: 0.92, blue: 0.92)

            VStack(spacing: 12) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.black.opacity(0.2))

                Text("Fotoğraf Ekle")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Toolbar Button
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

// MARK: - Calendar View
struct CalendarView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(localization.string("calendar_title"))
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.string("memory_timeline"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text(localization.string("calendar_desc"))
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(localization.string("profile_title"))
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.string("user_settings"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text(localization.string("profile_desc"))
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    ContentView()
}
