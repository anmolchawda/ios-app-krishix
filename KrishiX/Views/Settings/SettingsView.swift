import SwiftUI

public struct SettingsView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var showLanguagePicker: Bool = false
    @State private var showLegalModal: Bool = false
    @State private var legalModalTitle: String = ""
    @State private var legalModalContent: String = ""
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Preferences Section
                    settingsSectionHeader("PREFERENCES")
                    
                    VStack(spacing: 0) {
                        // Dark Theme Toggle
                        HStack {
                            Image(systemName: firebase.isDarkTheme ? "moon.stars.fill" : "sun.max.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 28)
                            Text("Dark Theme")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                            Toggle("", isOn: $firebase.isDarkTheme)
                                .labelsHidden()
                        }
                        .padding(14)
                        
                        Divider().padding(.horizontal, 14)
                        
                        // Language Selection
                        Button(action: { showLanguagePicker = true }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .frame(width: 28)
                                Text("Language")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(TranslationManager.supportedLanguages.first(where: { $0.code == translation.currentLanguage })?.nativeName ?? "English")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                    )
                    
                    // Support Section
                    settingsSectionHeader("SUPPORT & LEGAL")
                    
                    VStack(spacing: 0) {
                        // Kisan Call Center
                        Button(action: {
                            if let url = URL(string: "tel://18001801551") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kisan Call Center (Toll Free)")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text("1800-180-1551")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }
                        
                        Divider().padding(.horizontal, 14)
                        
                        // Privacy Policy
                        Button(action: {
                            legalModalTitle = "Privacy Policy"
                            legalModalContent = "KrishiX adheres to India's DPDP Act 2023. All farm telemetry and diagnostic images are stored securely on Google Cloud Firebase."
                            showLegalModal = true
                        }) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .frame(width: 28)
                                Text("Privacy Policy (DPDP Act 2023)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }
                        
                        Divider().padding(.horizontal, 14)
                        
                        // Terms of Service
                        Button(action: {
                            legalModalTitle = "Terms of Service"
                            legalModalContent = "By using KrishiX, farmers agree to CIB&RC and ICAR agronomic guidance standards."
                            showLegalModal = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .frame(width: 28)
                                Text("Terms of Service")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                    )
                    
                    // App Version Footer
                    VStack(spacing: 4) {
                        Text("KrishiX iOS Native v2.4.0 (Build 1)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("Powered by Google Firebase & Apple Silicon")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.top, 16)
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(isPresented: $showLanguagePicker)
        }
        .sheet(isPresented: $showLegalModal) {
            LegalDocModal(title: legalModalTitle, content: legalModalContent, isPresented: $showLegalModal)
        }
    }
    
    private func settingsSectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}
