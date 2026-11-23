import SwiftUI

public struct ProfileView: View {
    public var onOpenDrawer: () -> Void
    public var onOpenSettings: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    public init(onOpenDrawer: @escaping () -> Void, onOpenSettings: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Profile Header Card
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(red: 0.13, green: 0.55, blue: 0.28), Color(red: 0.10, green: 0.40, blue: 0.20)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 72, height: 72)
                                
                                Text(String((firebase.currentUser?.username.prefix(1) ?? "9")).uppercased())
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(firebase.currentUser?.username ?? "99side")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                        .font(.system(size: 16))
                                }
                                
                                Text(firebase.currentUser?.location ?? "Mumbai, Maharashtra")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                Text("Specialization: \(firebase.currentUser?.produce.first ?? "vegetable export")")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            
                            Spacer()
                        }
                        
                        // Stats row
                        HStack(spacing: 0) {
                            statItem(title: "Posts", count: "\(firebase.currentUser?.postCount ?? 4)")
                            statItem(title: "Followers", count: "\(firebase.currentUser?.followersCount ?? 142)")
                            statItem(title: "Following", count: "\(firebase.currentUser?.followingCount ?? 38)")
                        }
                        .padding(.vertical, 10)
                        .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.96, green: 0.97, blue: 0.98))
                        .cornerRadius(12)
                        
                        // Edit Profile Button
                        Button(action: onOpenSettings) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text(translation.getString("profileSettings"))
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    )
                    
                    // Farm details card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Farm Holdings & Registration")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                        
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Text("Operational Land: 5.0 Acres (Irrigated)")
                                .font(.system(size: 13))
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Text("Kisan Credit Card (KCC) Verified")
                                .font(.system(size: 13))
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                    )
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    private func statItem(title: String, count: String) -> some View {
        VStack(spacing: 2) {
            Text(count)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : .primary)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
