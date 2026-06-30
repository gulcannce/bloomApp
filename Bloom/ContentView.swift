import SwiftUI
import PhotosUI
import Combine

class CreateViewState: ObservableObject {
    @Published var processedImage: Image? = nil
}

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var localization = LocalizationManager()
    @StateObject private var memoryStore = MemoryStore.shared
    @State private var showCreateSheet = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @StateObject private var createViewState = CreateViewState()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                            NavigationStack {
                                HomeView(showCreateSheet: $showCreateSheet)
                                    .environmentObject(localization)
                                    .environmentObject(memoryStore)
                                    .environmentObject(createViewState)
                            }
                        case 1:
                        AnalyticsView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    case 2:
                        AchievementsView()
                            .environmentObject(localization)
                            .environmentObject(memoryStore)
                    case 3:
                        NavigationStack {
                            CalendarView()
                                .environmentObject(localization)
                                .environmentObject(memoryStore)
                        }
                    case 4:
                        ProfileView()
                            .environmentObject(localization)
                    default:
                        NavigationStack {
                            HomeView(showCreateSheet: $showCreateSheet)
                                .environmentObject(localization)
                                .environmentObject(memoryStore)
                                .environmentObject(createViewState)
                        }
                    }
                }

                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                CustomTabBarWithPhotoPicker(
                    selectedTab: $selectedTab,
                    selectedItem: $selectedItem
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: selectedItem) {
            Task {
                if let newItem = selectedItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                createViewState.processedImage = Image(uiImage: uiImage)
                                showCreateSheet = true
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateView(showCreateSheet: $showCreateSheet, selectedTab: $selectedTab)
                .environmentObject(localization)
                .environmentObject(memoryStore)
                .environmentObject(createViewState)
        }
    }
}

struct CustomTabBarWithPhotoPicker: View {
    @Binding var selectedTab: Int
    @Binding var selectedItem: PhotosPickerItem?

    let tabItems = [
        (icon: "house.fill", tag: 0, color: BloomTheme.driedRose),
        (icon: "chart.bar.fill", tag: 1, color: BloomTheme.sageGreen),
        (icon: "trophy.fill", tag: 2, color: Color(red: 0.88, green: 0.82, blue: 0.70)),
        (icon: "calendar", tag: 3, color: BloomTheme.siennaDust),
        (icon: "person.fill", tag: 4, color: Color(red: 0.70, green: 0.65, blue: 0.60))
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(BloomTheme.textTertiary.opacity(0.2))

            HStack(spacing: 0) {
                // Left side - Home
                VStack(spacing: 4) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 0 } }) {
                        Image(systemName: tabItems[0].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(tabItems[0].color.opacity(selectedTab == 0 ? 1.0 : 0.6))
                    }

                    if selectedTab == 0 {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(tabItems[0].color)
                            .frame(width: 16, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)

                // Stats
                VStack(spacing: 4) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 } }) {
                        Image(systemName: tabItems[1].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(tabItems[1].color.opacity(selectedTab == 1 ? 1.0 : 0.6))
                    }

                    if selectedTab == 1 {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(tabItems[1].color)
                            .frame(width: 16, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)

                // Center - Plus Button with PhotosPicker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BloomTheme.driedRose)
                }
                .frame(maxWidth: .infinity)

                // Achievements
                VStack(spacing: 4) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 2 } }) {
                        Image(systemName: tabItems[2].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(tabItems[2].color.opacity(selectedTab == 2 ? 1.0 : 0.6))
                    }

                    if selectedTab == 2 {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(tabItems[2].color)
                            .frame(width: 16, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)

                // Calendar
                VStack(spacing: 4) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 3 } }) {
                        Image(systemName: tabItems[3].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(tabItems[3].color.opacity(selectedTab == 3 ? 1.0 : 0.6))
                    }

                    if selectedTab == 3 {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(tabItems[3].color)
                            .frame(width: 16, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)

                // Right side - Profile
                VStack(spacing: 4) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 4 } }) {
                        Image(systemName: tabItems[4].icon)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(tabItems[4].color.opacity(selectedTab == 4 ? 1.0 : 0.6))
                    }

                    if selectedTab == 4 {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(tabItems[4].color)
                            .frame(width: 16, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
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
    ContentView()
        .environmentObject(CreateViewState())
}
