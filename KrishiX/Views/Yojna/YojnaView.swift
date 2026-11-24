import SwiftUI

public struct YojnaView: View {
    public var onOpenDrawer: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedCategory: String = "All"
    @State private var webViewUrl: String = ""
    @State private var webViewTitle: String = ""
    @State private var showWebView: Bool = false
    
    let categories = ["All", "Direct Income Support", "Crop Insurance", "Credit & Concessional Loans", "Soil Diagnostics"]
    
    public init(onOpenDrawer: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
        self.onBack = onBack
    }
    
    var filteredSchemes: [YojnaScheme] {
        if selectedCategory == "All" {
            return YojnaData.defaultSchemes
        }
        return YojnaData.defaultSchemes.filter { $0.category == selectedCategory }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer, showBackButton: true, onBack: onBack)
            
            // Sub-header with back button
            HStack {
                if let back = onBack {
                    Button(action: back) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Back")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                }
                
                Text("Government Schemes (योजना)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.16) : Color(red: 0.97, green: 0.98, blue: 0.99))
            
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            Text(cat)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(selectedCategory == cat ? .white : Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedCategory == cat ?
                                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                                    (firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color.white)
                                )
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color.white)
            
            // Scheme list
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredSchemes) { scheme in
                        schemeCard(scheme: scheme)
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
        .sheet(isPresented: $showWebView) {
            InAppPolicyWebViewModal(title: webViewTitle, urlString: webViewUrl, isPresented: $showWebView)
        }
    }
    
    private func schemeCard(scheme: YojnaScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category & Department
            HStack {
                Text(scheme.category)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                    .cornerRadius(6)
                
                Spacer()
                
                Text(scheme.department)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            // Title & Description
            Text(scheme.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            Text(scheme.description)
                .font(.system(size: 13))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                .lineSpacing(2)
            
            Divider()
            
            // Eligibility
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 13))
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Eligibility")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    Text(scheme.eligibility)
                        .font(.system(size: 12))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.9) : .black)
                }
            }
            
            // Benefits
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 13))
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Financial Benefit / Subsidy")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                    Text(scheme.benefits)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
            }
            
            // Action button
            Button(action: {
                webViewTitle = scheme.title
                webViewUrl = scheme.officialLink
                showWebView = true
            }) {
                HStack(spacing: 6) {
                    Text("Visit Official Portal")
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 13))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}
