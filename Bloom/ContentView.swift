import SwiftUI

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

            AchievementsView()
                .environmentObject(localization)
                .tabItem {
                    Label(localization.currentLanguage == .turkish ? "Başarımlar" : "Achievements", systemImage: "star.fill")
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

#Preview {
    ContentView()
}
