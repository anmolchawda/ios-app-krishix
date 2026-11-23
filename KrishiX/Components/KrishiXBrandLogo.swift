import SwiftUI
import UIKit

public struct KrishiXBrandLogo: View {
    public var height: CGFloat = 36
    public var showBanner: Bool = true
    
    @ObservedObject private var firebase = FirebaseManager.shared
    
    public init(height: CGFloat = 36, showBanner: Bool = true) {
        self.height = height
        self.showBanner = showBanner
    }
    
    public var body: some View {
        Group {
            if showBanner {
                if let uiImage = UIImage(named: firebase.isDarkTheme ? "KrishiXBannerDark" : "KrishiXBanner") ?? UIImage(named: "KrishiXBanner") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                } else {
                    bannerFallback
                }
            } else {
                if let uiImage = UIImage(named: firebase.isDarkTheme ? "KrishiXLogoDark" : "KrishiXLogo") ?? UIImage(named: "KrishiXLogo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                } else {
                    iconFallback
                }
            }
        }
    }
    
    private var bannerFallback: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .frame(width: height, height: height)
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: height * 0.55, height: height * 0.55)
                    .foregroundColor(.white)
            }
            Text("KrishiX")
                .font(.system(size: height * 0.75, weight: .black, design: .rounded))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.10, green: 0.25, blue: 0.15))
        }
    }
    
    private var iconFallback: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                .frame(width: height, height: height)
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: height * 0.55, height: height * 0.55)
                .foregroundColor(.white)
        }
    }
}
