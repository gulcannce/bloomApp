import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var localization = LocalizationManager()
    @StateObject private var memoryStore = MemoryStore.shared
    @State private var showCreateSheet = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    case 1:
                        StatsView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    case 2:
                        AchievementsView()
                            .environmentObject(localization)
                    case 3:
                        CalendarView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    case 4:
                        ProfileView()
                            .environmentObject(localization)
                    default:
                        HomeView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    }
                }

                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, showCreateSheet: $showCreateSheet)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateView()
                .environmentObject(localization)
                .environmentObject(memoryStore)
        }
    }
}

#Preview {
    ContentView()
}
