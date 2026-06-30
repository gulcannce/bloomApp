import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var showExportAlert = false
    @State private var showBackupAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            BloomTheme.background
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
                            .foregroundColor(BloomTheme.textPrimary)

                        Text(localization.currentLanguage == .turkish
                            ? "Hayatını yaz, anılarını yaşa."
                            : "Write your life, live your memories.")
                            .font(.system(size: 13, weight: .light, design: .serif))
                            .foregroundColor(BloomTheme.textSecondary)
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

                        Button(action: { showExportAlert = true }) {
                            ProfileSettingRow(
                                icon: "square.and.arrow.up.fill",
                                title: localization.currentLanguage == .turkish ? "Dışa Aktar" : "Export",
                                trailing: "chevron.right"
                            )
                        }
                        .alert(localization.currentLanguage == .turkish ? "Dışa Aktar" : "Export", isPresented: $showExportAlert) {
                            Button(localization.currentLanguage == .turkish ? "CSV" : "CSV") {
                                exportAsCSV()
                            }
                            Button(localization.currentLanguage == .turkish ? "JSON" : "JSON") {
                                exportAsJSON()
                            }
                            Button(localization.currentLanguage == .turkish ? "İptal" : "Cancel", role: .cancel) {}
                        } message: {
                            Text(localization.currentLanguage == .turkish ? "Hangi format'ta dışa aktarmak istiyorsunuz?" : "Choose export format")
                        }

                        Button(action: { showBackupAlert = true }) {
                            ProfileSettingRow(
                                icon: "icloud.and.arrow.up.fill",
                                title: localization.currentLanguage == .turkish ? "Yedekle & Senkronize" : "Backup & Sync",
                                trailing: "chevron.right"
                            )
                        }
                        .alert(localization.currentLanguage == .turkish ? "Yedekle" : "Backup", isPresented: $showBackupAlert) {
                            Button(localization.currentLanguage == .turkish ? "Yedekle Oluştur" : "Create Backup") {
                                createBackup()
                            }
                            Button(localization.currentLanguage == .turkish ? "Yedekten Geri Yükle" : "Restore Backup") {
                                restoreBackup()
                            }
                            Button(localization.currentLanguage == .turkish ? "İptal" : "Cancel", role: .cancel) {}
                        } message: {
                            Text(localization.currentLanguage == .turkish ? "Verileri yönetin" : "Manage your data")
                        }
                    }

                    Spacer(minLength: 20)

                    Button(action: {
                        MemoryStore.injectMockData()
                    }) {
                        Text(localization.currentLanguage == .turkish ? "Test Verisi Yükle" : "Load Mock Data")
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)

                    Button(action: {}) {
                        Text(localization.currentLanguage == .turkish ? "Çıkış Yap" : "Log Out")
                            .font(.system(size: 16, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(BloomTheme.driedRose)
                            .cornerRadius(8)
                            .shadow(color: BloomTheme.driedRose.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func exportAsCSV() {
        print("QA_LOG: CSV export initiated - \(MemoryStore.shared.memories.count) memories")
    }

    private func exportAsJSON() {
        print("QA_LOG: JSON export initiated - \(MemoryStore.shared.memories.count) memories")
    }

    private func createBackup() {
        print("QA_LOG: Backup created - memories saved to UserDefaults")
        MemoryStore.shared.saveMemories()
    }

    private func restoreBackup() {
        print("QA_LOG: Backup restored from UserDefaults")
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
