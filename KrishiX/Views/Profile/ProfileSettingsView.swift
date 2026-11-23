import SwiftUI

public struct ProfileSettingsView: View {
    public var onBack: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var displayName: String = "99side"
    @State private var location: String = "Mumbai, Maharashtra"
    @State private var specialization: String = "vegetable export"
    @State private var showSavedAlert: Bool = false
    
    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Nav Bar
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text(translation.getString("backToProfile"))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
                
                Spacer()
                
                Text(translation.getString("profileSettings"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Spacer()
                
                Color.clear.frame(width: 80, height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(firebase.isDarkTheme ? Color(red: 0.12, green: 0.13, blue: 0.15) : Color.white)
            
            ScrollView {
                VStack(spacing: 18) {
                    // Avatar & Change Photo
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.13, green: 0.55, blue: 0.28), Color(red: 0.10, green: 0.40, blue: 0.20)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 84, height: 84)
                            
                            Text("9")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Text("Change Photo")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        }
                    }
                    .padding(.top, 10)
                    
                    // DPDP Act Compliance Notice Banner
                    dpdpComplianceBanner
                    
                    // Form Fields
                    VStack(spacing: 14) {
                        // Username (Locked)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text(firebase.currentUser?.username ?? "99side")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 11))
                                    Text("Cannot be changed")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                            .cornerRadius(10)
                        }
                        
                        // Display Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Display Name")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Display Name", text: $displayName)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                                .cornerRadius(10)
                                .foregroundColor(firebase.isDarkTheme ? .white : .black)
                        }
                        
                        // Phone Number (Locked)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Phone Number")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text(firebase.currentUser?.phoneNumber ?? "+91 9999999999")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 11))
                                    Text("Verified")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            .padding(12)
                            .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                            .cornerRadius(10)
                        }
                        
                        // Location
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Location", text: $location)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                                .cornerRadius(10)
                                .foregroundColor(firebase.isDarkTheme ? .white : .black)
                        }
                        
                        // Specialization / Produce
                        VStack(alignment: .leading, spacing: 4) {
                            Text(translation.getString("specialization"))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Specialization (e.g. vegetable export)", text: $specialization)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                                .cornerRadius(10)
                                .foregroundColor(firebase.isDarkTheme ? .white : .black)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                    )
                    
                    // Save Changes Button
                    Button(action: saveChanges) {
                        HStack {
                            Text(translation.getString("saveChanges"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                        .cornerRadius(12)
                    }
                    
                    if showSavedAlert {
                        Text("Profile updated successfully!")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    private var dpdpComplianceBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                .font(.system(size: 18))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("DPDP Act 2023 Compliant")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                Text("Your personal data is encrypted and securely stored. We do not sell your data.")
                    .font(.system(size: 11))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
            }
        }
        .padding(14)
        .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
        .cornerRadius(12)
    }
    
    private func saveChanges() {
        firebase.currentUser?.displayName = displayName
        firebase.currentUser?.location = location
        firebase.currentUser?.produce = [specialization]
        withAnimation {
            showSavedAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedAlert = false
            }
        }
    }
}
