import SwiftUI

public struct AuthView: View {
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var phoneNumber: String = "9999999999"
    @State private var agreedToTerms: Bool = true
    @State private var isOtpStep: Bool = false
    @State private var otpCode: String = ""
    @State private var showSmsBanner: Bool = false
    @State private var smsCode: String = "849201"
    
    @State private var showLanguagePicker: Bool = false
    @State private var showWebViewModal: Bool = false
    @State private var webViewTitle: String = ""
    @State private var webViewUrl: String = ""
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            (firebase.isDarkTheme ? Color(red: 0.08, green: 0.09, blue: 0.11) : Color(red: 0.98, green: 0.98, blue: 0.99))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top control bar: Dark mode & Language pills
                HStack {
                    Button(action: {
                        withAnimation {
                            firebase.isDarkTheme.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: firebase.isDarkTheme ? "moon.stars.fill" : "sun.max.fill")
                                .font(.system(size: 13))
                            Text(firebase.isDarkTheme ? "Dark" : "Light")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color.white)
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    Button(action: { showLanguagePicker = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 13))
                            Text(TranslationManager.supportedLanguages.first(where: { $0.code == translation.currentLanguage })?.englishName ?? "English")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color.white)
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Card Container
                VStack(spacing: 24) {
                    // Large Crisp Brand Logo
                    KrishiXBrandLogo(height: 52, showBanner: true)
                        .padding(.bottom, 6)
                    
                    VStack(spacing: 6) {
                        Text(isOtpStep ? translation.getString("enterOtpTitle") : translation.getString("welcomeTitle"))
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                            .tracking(1)
                        
                        Text(isOtpStep ? "\(translation.getString("otpSubtitle")) +91 \(phoneNumber)" : translation.getString("startConnectingSubtitle"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    if !isOtpStep {
                        phoneInputSection
                    } else {
                        otpInputSection
                    }
                }
                .padding(28)
                .background(
                    (firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Copyright footer
                Text("© 2023 KrishiX. All rights reserved.")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(.bottom, 24)
            }
            
            // In-app SMS notification simulation banner
            if showSmsBanner {
                smsNotificationBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(isPresented: $showLanguagePicker)
        }
        .sheet(isPresented: $showWebViewModal) {
            InAppPolicyWebViewModal(title: webViewTitle, urlString: webViewUrl, isPresented: $showWebViewModal)
        }
    }
    
    // MARK: - Phone Input
    private var phoneInputSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text("🇮🇳")
                        .font(.system(size: 16))
                    Text("+91")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.95, green: 0.96, blue: 0.97))
                .cornerRadius(12)
                
                TextField(translation.getString("phonePlaceholder"), text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.95, green: 0.96, blue: 0.97))
                    .cornerRadius(12)
                    .foregroundColor(firebase.isDarkTheme ? .white : .black)
            }
            
            // Terms of Service & Privacy Policy checkbox with clickable in-app links
            HStack(alignment: .top, spacing: 10) {
                Button(action: { agreedToTerms.toggle() }) {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(agreedToTerms ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(translation.getString("termsPrefix"))
                        .font(.system(size: 12))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
                    
                    HStack(spacing: 4) {
                        Button(action: {
                            webViewTitle = translation.getString("termsAndConditionsLink")
                            webViewUrl = "https://krishix.co.in/terms"
                            showWebViewModal = true
                        }) {
                            Text(translation.getString("termsAndConditionsLink"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .underline()
                        }
                        
                        Text(translation.getString("and"))
                            .font(.system(size: 12))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
                        
                        Button(action: {
                            webViewTitle = translation.getString("privacyPolicyLink")
                            webViewUrl = "https://krishix.co.in/privacy"
                            showWebViewModal = true
                        }) {
                            Text(translation.getString("privacyPolicyLink"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .underline()
                        }
                    }
                }
            }
            .padding(.top, 4)
            
            // Verify Button
            Button(action: triggerOtpVerification) {
                HStack {
                    Text(translation.getString("getOtpButton"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    (agreedToTerms && phoneNumber.count >= 10) ?
                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                    Color.gray.opacity(0.4)
                )
                .cornerRadius(14)
            }
            .disabled(!agreedToTerms || phoneNumber.count < 10)
        }
    }
    
    // MARK: - OTP Input
    private var otpInputSection: some View {
        VStack(spacing: 20) {
            TextField("••••••", text: $otpCode)
                .keyboardType(.numberPad)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.95, green: 0.96, blue: 0.97))
                .cornerRadius(12)
                .foregroundColor(firebase.isDarkTheme ? .white : .black)
            
            Button(action: verifyOtpAndLogin) {
                HStack {
                    Text(translation.getString("verifyOtpButton"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    otpCode.count >= 4 ?
                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                    Color.gray.opacity(0.4)
                )
                .cornerRadius(14)
            }
            .disabled(otpCode.count < 4)
            
            HStack {
                Button(action: {
                    withAnimation {
                        isOtpStep = false
                        otpCode = ""
                        showSmsBanner = false
                    }
                }) {
                    Text(translation.getString("changeNumber"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
                
                Spacer()
                
                Button(action: {
                    triggerOtpVerification()
                }) {
                    Text(translation.getString("resendOtpLink"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Interactive SMS Notification Banner
    private var smsNotificationBanner: some View {
        Button(action: {
            otpCode = smsCode
            withAnimation {
                showSmsBanner = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "message.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 22))
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("MESSAGES • now")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Tap to autofill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                    Text("KrishiX Verification Code: \(smsCode). Valid for 10 minutes.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(firebase.isDarkTheme ? Color(red: 0.20, green: 0.22, blue: 0.26) : Color.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    private func triggerOtpVerification() {
        withAnimation {
            isOtpStep = true
            showSmsBanner = true
            smsCode = "849201"
        }
        
        // Auto-dismiss the simulated SMS banner after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            withAnimation {
                showSmsBanner = false
            }
        }
    }
    
    private func verifyOtpAndLogin() {
        _ = firebase.loginWithPhone(phoneNumber: phoneNumber, otp: otpCode)
    }
}
