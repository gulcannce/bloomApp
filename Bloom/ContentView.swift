import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Anasayfa", systemImage: "house.fill")
                }
                .tag(0)

            StatsView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.fill")
                }
                .tag(1)

            CreateView()
                .tabItem {
                    Label("Yeni Anı", systemImage: "plus.circle.fill")
                }
                .tag(2)

            CalendarView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.black.opacity(0.7))
    }
}

// MARK: - Home View (Existing Polaroid/Carousel)
struct HomeView: View {
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
                Text("Bloom")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

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
                        Text("Anı")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.black.opacity(0.7))
                        Text("28 Haziran 2026")
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
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("İstatistikler")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Mood Tracking")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text("Placeholder for mood statistics and analytics.")
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

// MARK: - Create View
struct CreateView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Yeni Anı")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.black.opacity(0.3))
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Takvim")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Memory Timeline")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text("Placeholder for memory calendar and timeline view.")
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
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Profil")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .tracking(1.0)
                    .foregroundColor(.black.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    Text("User Settings")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))

                    Text("Placeholder for user profile and settings.")
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
