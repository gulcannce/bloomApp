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
                CustomTabBarWithPhotoPicker(
                    selectedTab: $selectedTab,
                    selectedItem: $selectedItem
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let newItem = newItem {
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
            CreateView()
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
        (icon: "house.fill", tag: 0, color: Color(red: 0.72, green: 0.55, blue: 0.50)),
        (icon: "chart.bar.fill", tag: 1, color: BloomTheme.sageGreen),
        (icon: "star.fill", tag: 2, color: Color(red: 0.82, green: 0.75, blue: 0.55)),
        (icon: "calendar", tag: 3, color: Color(red: 0.68, green: 0.60, blue: 0.50)),
        (icon: "person.fill", tag: 4, color: Color(red: 0.70, green: 0.65, blue: 0.60))
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

                // Center - Plus Button with PhotosPicker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BloomTheme.driedRose)
                }
                .frame(maxWidth: .infinity)

                // Right side - 2 items (Achievements, Calendar, Profile)
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
    ContentView()
}
