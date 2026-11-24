import SwiftUI

public struct AuthView: View {
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var phoneNumber: String = "9999999999"
    @State private var agreedToTerms: Bool = true
    @State private var isOtpStep: Bool = false
    @State private var otpCode: String = ""
    @State private var isSendingOtp: Bool = false
    @State private var isVerifying: Bool = false
    @State private var errorMessage: String? = nil
    
    // In-app SMS Banner Simulation matching real Firebase SMS notification
    @State private var showSmsBanner: Bool = false
    @State private var smsCode: String = "163420"
    
    // Countdown Timers
    @State private var otpValiditySeconds: Int = 300 // 5:00 minutes
    @State private var resendCooldownSeconds: Int = 60
    @State private var timerSubscription: Timer? = nil
    
    // Policy Sheets
    @State private var showLanguagePicker: Bool = false
    @State private var showWebViewModal: Bool = false
    @State private var webViewTitle: String = ""
    @State private var webViewUrl: String = ""
    
    public init() {}
    
    var formattedValidityTime: String {
        let minutes = otpValiditySeconds / 60
        let seconds = otpValiditySeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            (firebase.isDarkTheme ? Color(red: 0.08, green: 0.09, blue: 0.11) : Color(red: 0.98, green: 0.98, blue: 0.99))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top control bar: Dark mode & Language pills
                topControlBar
                
                Spacer()
                
                // Main Auth Card Container
                VStack(spacing: 22) {
                    // Large Crisp Prominent Brand Logo (Point 1 fix)
                    KrishiXBrandLogo(height: 64, showBanner: true)
                        .padding(.bottom, 4)
                    
                    if !isOtpStep {
                        VStack(spacing: 6) {
                            Text(translation.getString("welcomeTitle"))
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                                .tracking(1)
                            
                            Text(translation.getString("startConnectingSubtitle"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        phoneInputSection
                    } else {
                        otpInputSection
                    }
                    
                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(26)
                .background(
                    (firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Footer
                Text("© 2026 KrishiX • Digital India Agriculture")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(.bottom, 24)
            }
            
            // In-app realistic SMS notification matching krishix-aistudio-3090db.firebaseapp.com
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
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Top Control Bar
    private var topControlBar: some View {
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
    }
    
    // MARK: - 1. Phone Input Section
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.35), lineWidth: 1.5)
                    )
                    .foregroundColor(firebase.isDarkTheme ? .white : .black)
            }
            
            // Terms of Service & Privacy Policy Checkbox (Point 2 Fix with In-App Browser)
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
            
            // Verify Button -> (Video UX: "Verify ->")
            Button(action: requestOtpFromFirebase) {
                HStack(spacing: 8) {
                    if isSendingOtp {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Verify  →")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    (agreedToTerms && phoneNumber.count >= 10 && !isSendingOtp) ?
                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                    Color.gray.opacity(0.4)
                )
                .cornerRadius(14)
            }
            .disabled(!agreedToTerms || phoneNumber.count < 10 || isSendingOtp)
        }
    }
    
    // MARK: - 2. OTP Input Section (Matching Video Frames: login_2.7s.jpg)
    private var otpInputSection: some View {
        VStack(spacing: 16) {
            // Selected Phone & Change Number Row
            HStack {
                HStack(spacing: 6) {
                    Text("🇮🇳 +91 \(phoneNumber)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.94, green: 0.95, blue: 0.96))
                .cornerRadius(8)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isOtpStep = false
                        otpCode = ""
                        showSmsBanner = false
                        stopTimer()
                    }
                }) {
                    Text("Change Number")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
            }
            
            VStack(spacing: 4) {
                Text("Enter OTP")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Text("Enter the 6-digit code sent to your phone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
            
            // OTP Input Field
            TextField("OTP here", text: $otpCode)
                .keyboardType(.numberPad)
                .font(.system(size: 26, weight: .heavy, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.95, green: 0.96, blue: 0.97))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.4), lineWidth: 1.5)
                )
                .foregroundColor(firebase.isDarkTheme ? .white : .black)
            
            // Valid for: 05:00 Pill (Matching Video Frame)
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 12))
                
                Text("Valid for: \(formattedValidityTime)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
            .cornerRadius(16)
            
            // Verify Button (Matching Video Frame: "✓ Verify")
            Button(action: verifyOtpCode) {
                HStack(spacing: 8) {
                    if isVerifying {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                        Text("Verify")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundColor(.white)
                .background(
                    otpCode.count >= 6 && !isVerifying ?
                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                    Color.gray.opacity(0.4)
                )
                .cornerRadius(14)
            }
            .disabled(otpCode.count < 6 || isVerifying)
            
            // Resend Countdown
            if resendCooldownSeconds > 0 {
                Text("You can resend in \(resendCooldownSeconds) seconds")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            } else {
                Button(action: {
                    requestOtpFromFirebase()
                }) {
                    Text("Resend OTP")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Interactive SMS Notification Banner (Exact Firebase Auth SMS simulation)
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
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Tap to autofill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                    Text("\(smsCode) is your verification code for krishix-aistudio-3090db.firebaseapp.com")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
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
    
    // MARK: - Auth Actions
    private func requestOtpFromFirebase() {
        errorMessage = nil
        isSendingOtp = true
        
        firebase.sendOtp(phoneNumber: phoneNumber) { result in
            isSendingOtp = false
            switch result {
            case .success(let code):
                smsCode = code
                withAnimation {
                    isOtpStep = true
                    showSmsBanner = true
                }
                startTimers()
                
                // Auto-dismiss banner after 8s
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    withAnimation {
                        showSmsBanner = false
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func verifyOtpCode() {
        errorMessage = nil
        isVerifying = true
        
        firebase.verifyOtp(code: otpCode, phoneNumber: phoneNumber) { result in
            isVerifying = false
            switch result {
            case .success:
                stopTimer()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func startTimers() {
        stopTimer()
        otpValiditySeconds = 300
        resendCooldownSeconds = 60
        
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.otpValiditySeconds > 0 {
                    self.otpValiditySeconds -= 1
                }
                if self.resendCooldownSeconds > 0 {
                    self.resendCooldownSeconds -= 1
                }
            }
        }
    }
    
    private func stopTimer() {
        timerSubscription?.invalidate()
        timerSubscription = nil
    }
}
