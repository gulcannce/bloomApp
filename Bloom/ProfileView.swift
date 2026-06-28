import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.black.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 2))

                        Text("Bloom Girl")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundColor(.black.opacity(0.8))

                        Text(localization.currentLanguage == .turkish
                            ? "Hayatını yaz, anılarını yaşa."
                            : "Write your life, live your memories.")
                            .font(.system(size: 14, weight: .light, design: .default))
                            .foregroundColor(.black.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32)

                    Divider()
                        .padding(.horizontal, 20)

                    VStack(spacing: 0) {
                        ProfileSettingRow(
                            icon: "person.text.rectangle.fill",
                            title: localization.currentLanguage == .turkish ? "Kişisel Bilgiler" : "Personal Info",
                            trailing: "chevron.right"
                        )

                        ProfileSettingRow(
                            icon: "gearshape.fill",
                            title: localization.currentLanguage == .turkish ? "Ayarlar" : "Settings",
                            trailing: "chevron.right"
                        )

                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.black.opacity(0.5))
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.currentLanguage == .turkish ? "Dil" : "Language")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black.opacity(0.8))
                            }

                            Spacer()

                            Picker("", selection: Binding(
                                get: { localization.currentLanguage },
                                set: { localization.currentLanguage = $0 }
                            )) {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 140)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.8))
                        .overlay(Divider(), alignment: .bottom)

                        ProfileSettingRow(
                            icon: "square.and.arrow.up.fill",
                            title: localization.currentLanguage == .turkish ? "Dışa Aktar" : "Export",
                            trailing: "chevron.right"
                        )

                        ProfileSettingRow(
                            icon: "icloud.and.arrow.up.fill",
                            title: localization.currentLanguage == .turkish ? "Yedekle & Senkronize" : "Backup & Sync",
                            trailing: "chevron.right"
                        )
                    }

                    Spacer(minLength: 40)

                    Button(action: {
                        print("QA_LOG: Logout triggered")
                    }) {
                        Text(localization.currentLanguage == .turkish ? "Çıkış Yap" : "Log Out")
                            .font(.system(size: 16, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color(red: 0.8, green: 0.3, blue: 0.3))
                            .cornerRadius(8)
                            .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.3).opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct ProfileSettingRow: View {
    let icon: String
    let title: String
    let trailing: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.black.opacity(0.5))
                .frame(width: 24)

            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black.opacity(0.8))

            Spacer()

            Image(systemName: trailing)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.black.opacity(0.3))
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .overlay(Divider(), alignment: .bottom)
    }
}
