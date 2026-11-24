import SwiftUI

public struct ContentView: View {
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var isDrawerOpen: Bool = false
    
    public init() {}
    
    public var body: some View {
        Group {
            if !firebase.isLoggedIn {
                AuthView()
            } else {
                ZStack {
                    VStack(spacing: 0) {
                        // Main View Router
                        ZStack {
                            switch selectedTab {
                            case 0:
                                FeedView(onOpenDrawer: { isDrawerOpen = true })
                            case 1:
                                GuideView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onBack: { selectedTab = 0 }
                                )
                            case 2:
                                AiDoctorView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onBack: { selectedTab = 0 }
                                )
                            case 3:
                                WeatherView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onBack: { selectedTab = 0 }
                                )
                            case 4:
                                MandiView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onBack: { selectedTab = 0 }
                                )
                            case 5:
                                RadarView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onConsultDoctor: { selectedTab = 2 },
                                    onBack: { selectedTab = 0 }
                                )
                            case 6:
                                ProfileSettingsView(onBack: { selectedTab = 0 })
                            case 7:
                                YojnaView(
                                    onOpenDrawer: { isDrawerOpen = true },
                                    onBack: { selectedTab = 0 }
                                )
                            default:
                                FeedView(onOpenDrawer: { isDrawerOpen = true })
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Custom Bottom Tab Bar
                        bottomTabBar
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    // Side Navigation Drawer
                    KrishiSideDrawer(isOpen: $isDrawerOpen, selectedTab: $selectedTab)
                }
            }
        }
    }
    
    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "newspaper.fill", title: translation.getString("feed"), tabIndex: 0)
            tabBarItem(icon: "book.fill", title: translation.getString("guide"), tabIndex: 1)
            tabBarItem(icon: "stethoscope", title: translation.getString("aiDoctor"), tabIndex: 2)
            tabBarItem(icon: "cloud.sun.fill", title: translation.getString("weather"), tabIndex: 3)
            tabBarItem(icon: "chart.line.uptrend.xyaxis", title: translation.getString("mandi"), tabIndex: 4)
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            (firebase.isDarkTheme ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -2)
        )
    }
    
    private func tabBarItem(icon: String, title: String, tabIndex: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tabIndex
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: selectedTab == tabIndex ? .bold : .regular))
                    .foregroundColor(selectedTab == tabIndex ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
                
                Text(title)
                    .font(.system(size: 10, weight: selectedTab == tabIndex ? .bold : .medium))
                    .foregroundColor(selectedTab == tabIndex ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
