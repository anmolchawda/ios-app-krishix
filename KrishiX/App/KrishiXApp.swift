import SwiftUI
import FirebaseCore

@main
struct KrishiXApp: App {
    @StateObject private var firebase = FirebaseManager.shared
    @StateObject private var translation = TranslationManager.shared
    
    init() {
        FirebaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(firebase.isDarkTheme ? .dark : .light)
        }
    }
}
