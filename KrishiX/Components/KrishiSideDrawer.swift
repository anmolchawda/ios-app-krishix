import SwiftUI

public struct KrishiSideDrawer: View {
    @Binding public var isOpen: Bool
    @Binding public var selectedTab: Int
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var showLanguagePicker: Bool = false
    @State private var showWebViewModal: Bool = false
    @State private var webViewTitle: String = ""
    @State private var webViewUrl: String = ""
    
    public init(isOpen: Binding<Bool>, selectedTab: Binding<Int>) {
        self._isOpen = isOpen
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }
                
                drawerContent
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(isPresented: $showLanguagePicker)
        }
        .sheet(isPresented: $showWebViewModal) {
            InAppPolicyWebViewModal(title: webViewTitle, urlString: webViewUrl, isPresented: $showWebViewModal)
        }
    }
    
    private var drawerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.13, green: 0.55, blue: 0.28), Color(red: 0.10, green: 0.40, blue: 0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 52, height: 52)
                        
                        Text(String((firebase.currentUser?.username.prefix(1) ?? "K")).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Text(firebase.currentUser?.username ?? "99side")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .font(.system(size: 14))
                        }
                        
                        Text(firebase.currentUser?.location ?? "Mumbai, Maharashtra")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("PREMIUM MEMBER")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                            .cornerRadius(4)
                    }
                }
                
                Divider()
            }
            .padding(20)
            .background(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.16) : Color(red: 0.97, green: 0.98, blue: 0.99))
            
            // Nav Items
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    drawerItem(icon: "newspaper.fill", title: translation.getString("feed"), tabIndex: 0)
                    drawerItem(icon: "stethoscope", title: translation.getString("aiDoctor"), tabIndex: 2)
                    drawerItem(icon: "cloud.sun.fill", title: translation.getString("weather"), tabIndex: 3)
                    drawerItem(icon: "chart.line.uptrend.xyaxis", title: translation.getString("mandi"), tabIndex: 4)
                    drawerItem(icon: "book.fill", title: translation.getString("guide"), tabIndex: 1)
                    drawerItem(icon: "dot.radiowaves.left.and.right", title: translation.getString("radar"), tabIndex: 5)
                    drawerItem(icon: "building.columns.fill", title: "Government Schemes (योजना)", tabIndex: 7)
                    drawerItem(icon: "person.crop.circle.fill", title: translation.getString("profileSettings"), tabIndex: 6)
                    
                    Divider().padding(.vertical, 8)
                    
                    // Dark theme toggle
                    HStack {
                        Image(systemName: firebase.isDarkTheme ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .frame(width: 28)
                        Text(firebase.isDarkTheme ? "Dark Mode" : "Light Mode")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                        Spacer()
                        Toggle("", isOn: $firebase.isDarkTheme)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // Language Switcher
                    Button(action: { showLanguagePicker = true }) {
                        HStack {
                            Image(systemName: "globe")
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 28)
                            Text("Language")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                            Spacer()
                            Text(TranslationManager.supportedLanguages.first(where: { $0.code == translation.currentLanguage })?.nativeName ?? "English")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    
                    // Help & Support
                    Button(action: {
                        if let url = URL(string: "tel://18001801551") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Kisan Call Center")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                                Text("1800-180-1551 (Toll Free)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    
                    // In-app Privacy & Terms
                    Button(action: {
                        webViewTitle = "Privacy Policy"
                        webViewUrl = "https://krishix.co.in/privacy"
                        showWebViewModal = true
                    }) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 28)
                            Text("Privacy & Terms")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 10)
            }
            
            Divider()
            
            // Footer: Logout
            Button(action: {
                withAnimation {
                    isOpen = false
                    firebase.isLoggedIn = false
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text(translation.getString("logout"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(firebase.isDarkTheme ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color.white)
        .ignoresSafeArea(.all, edges: .vertical)
    }
    
    private func drawerItem(icon: String, title: String, tabIndex: Int) -> some View {
        Button(action: {
            selectedTab = tabIndex
            withAnimation(.easeInOut(duration: 0.2)) {
                isOpen = false
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(selectedTab == tabIndex ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 15, weight: selectedTab == tabIndex ? .bold : .regular))
                    .foregroundColor(selectedTab == tabIndex ? Color(red: 0.13, green: 0.55, blue: 0.28) : (firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22)))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                selectedTab == tabIndex ?
                Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12) :
                Color.clear
            )
            .cornerRadius(8)
            .padding(.horizontal, 8)
        }
    }
}

public struct LanguagePickerSheet: View {
    @Binding public var isPresented: Bool
    @ObservedObject private var translation = TranslationManager.shared
    
    public var body: some View {
        NavigationView {
            List(TranslationManager.supportedLanguages) { lang in
                Button(action: {
                    translation.currentLanguage = lang.code
                    isPresented = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.nativeName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(lang.englishName)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if translation.currentLanguage == lang.code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Language")
            .navigationBarItems(trailing: Button("Done") { isPresented = false })
        }
    }
}

public struct LegalDocModal: View {
    public let title: String
    public let content: String
    @Binding public var isPresented: Bool
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(content)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Close") { isPresented = false })
        }
    }
}
