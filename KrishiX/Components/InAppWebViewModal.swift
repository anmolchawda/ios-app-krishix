import SwiftUI
import WebKit

public struct InAppWebView: UIViewRepresentable {
    public let url: URL
    @Binding public var isLoading: Bool
    
    public init(url: URL, isLoading: Binding<Bool> = .constant(false)) {
        self.url = url
        self._isLoading = isLoading
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        webView.load(request)
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: InAppWebView
        
        init(_ parent: InAppWebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}

public struct InAppPolicyWebViewModal: View {
    public let title: String
    public let urlString: String
    @Binding public var isPresented: Bool
    
    @State private var isLoading: Bool = true
    @ObservedObject private var firebase = FirebaseManager.shared
    
    public init(title: String, urlString: String, isPresented: Binding<Bool>) {
        self.title = title
        self.urlString = urlString
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if let url = URL(string: urlString) {
                    InAppWebView(url: url, isLoading: $isLoading)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Invalid URL")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.13, green: 0.55, blue: 0.28)))
                        Text("Loading secure policy document...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background((firebase.isDarkTheme ? Color.black : Color.white).opacity(0.85))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Text("krishix.co.in")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : .black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                }
            }
        }
    }
}
