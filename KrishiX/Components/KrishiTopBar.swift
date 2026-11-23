import SwiftUI

public struct KrishiTopBar: View {
    public var onOpenDrawer: () -> Void
    public var onSearch: (() -> Void)? = nil
    public var onNotifications: (() -> Void)? = nil
    public var onChat: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    
    public init(
        onOpenDrawer: @escaping () -> Void,
        onSearch: (() -> Void)? = nil,
        onNotifications: (() -> Void)? = nil,
        onChat: (() -> Void)? = nil
    ) {
        self.onOpenDrawer = onOpenDrawer
        self.onSearch = onSearch
        self.onNotifications = onNotifications
        self.onChat = onChat
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpenDrawer) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.20))
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            
            // Prominent Brand Logo
            KrishiXBrandLogo(height: 34, showBanner: true)
            
            Spacer()
            
            HStack(spacing: 6) {
                Button(action: { onSearch?() }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                        .frame(width: 36, height: 36)
                }
                
                Button(action: { onNotifications?() }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                            .frame(width: 36, height: 36)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: -4, y: 6)
                    }
                }
                
                Button(action: { onChat?() }) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                        .frame(width: 36, height: 36)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            (firebase.isDarkTheme ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
        )
    }
}
