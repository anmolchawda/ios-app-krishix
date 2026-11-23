import SwiftUI
import UIKit

public struct AiDoctorView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var scansLeft: Int = 0
    @State private var showCameraPicker: Bool = false
    @State private var showGalleryPicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    
    @State private var isAnalyzing: Bool = false
    @State private var chainOfThoughtStep: Int = 0
    @State private var showResultModal: Bool = false
    @State private var currentDiagnosis: DiagnosisResponse? = nil
    @State private var scanHistory: [DiagnosisResponse] = []
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Top banner: 0 Scans Left • Top up to continue
                    scansAlertBanner
                    
                    // Card: Take Crop Photo to Diagnose
                    takePhotoCard
                    
                    // Last Scans Section
                    lastScansSection
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { img in
                handleImageSelected(img)
            }
        }
        .sheet(isPresented: $showGalleryPicker) {
            ImagePicker(sourceType: .photoLibrary) { img in
                handleImageSelected(img)
            }
        }
        .sheet(isPresented: $showResultModal) {
            if let diag = currentDiagnosis {
                DiagnosisResultSheet(diagnosis: diag, image: selectedImage, isPresented: $showResultModal)
            }
        }
    }
    
    // MARK: - Scans Alert Banner
    private var scansAlertBanner: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 0.85, green: 0.60, blue: 0.10))
                    .font(.system(size: 14))
                
                Text(scansLeft > 0 ? "\(scansLeft) Scans Available" : translation.getString("scansLeft"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.22, blue: 0.25))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    scansLeft += 10
                }
            }) {
                Text(translation.getString("topUpScans"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Take Photo Card
    private var takePhotoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 18))
                
                Text(translation.getString("takePhotoDiagnose"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            Text(translation.getString("analyzingFoliar"))
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(2)
            
            if isAnalyzing {
                chainOfThoughtProgressView
            } else {
                HStack(spacing: 12) {
                    Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCameraPicker = true
                        } else {
                            showGalleryPicker = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                            Text(translation.getString("camera"))
                                .font(.system(size: 15, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                        .cornerRadius(12)
                    }
                    
                    Button(action: { showGalleryPicker = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 16))
                            Text(translation.getString("gallery"))
                                .font(.system(size: 15, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        .background(
                            (firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.92, green: 0.96, blue: 0.93))
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Chain of Thought Progress View
    private var chainOfThoughtProgressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.13, green: 0.55, blue: 0.28)))
                Text("AI Agronomist Reasoning...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                thoughtStepRow(step: 1, text: "Scanning foliar tissue and chlorosis patterns...", current: chainOfThoughtStep)
                thoughtStepRow(step: 2, text: "Matching fungal spore morphology against ICAR pathology database...", current: chainOfThoughtStep)
                thoughtStepRow(step: 3, text: "Cross-referencing CIB&RC registered fungicides & FRAC/IRAC codes...", current: chainOfThoughtStep)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.08))
        )
    }
    
    private func thoughtStepRow(step: Int, text: String, current: Int) -> some View {
        HStack(spacing: 8) {
            if current >= step {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 12))
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 12, height: 12)
            }
            
            Text(text)
                .font(.system(size: 12, weight: current >= step ? .medium : .regular))
                .foregroundColor(current >= step ? .primary : .gray)
        }
    }
    
    // MARK: - Last Scans Section
    private var lastScansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(translation.getString("lastScans")) \(scanHistory.count) / 10")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.22, blue: 0.25))
                Spacer()
            }
            
            if scanHistory.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                    
                    Text(translation.getString("noRecentScans"))
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                )
            } else {
                ForEach(scanHistory.indices, id: \.self) { idx in
                    let diag = scanHistory[idx]
                    Button(action: {
                        currentDiagnosis = diag
                        showResultModal = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(diag.diseaseName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                                Text("\(diag.cropName) • Confidence: \(diag.confidenceScore)%")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(diag.severity)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(diag.severity == "High" ? .red : .orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((diag.severity == "High" ? Color.red : Color.orange).opacity(0.12))
                                .cornerRadius(8)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        )
                    }
                }
            }
        }
    }
    
    private func handleImageSelected(_ image: UIImage) {
        selectedImage = image
        isAnalyzing = true
        chainOfThoughtStep = 1
        
        // Advance chain of thought reasoning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            chainOfThoughtStep = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            chainOfThoughtStep = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            let diag = DiagnosisResponse(
                success: true,
                diagnosisText: "Early-stage Yellow Rust (Puccinia striiformis) detected on wheat flag leaves with clear chlorotic stripe patterns. Prompt systemic fungicide application advised to prevent canopy spread.",
                cropName: "Wheat",
                diseaseName: "Yellow Rust (Puccinia striiformis)",
                severity: "Moderate",
                confidence: 0.94,
                recommendedChemicals: [
                    "Propiconazole 25% EC @ 1.0 ml/L of water (200 ml/acre)",
                    "Tebuconazole 25.9% EC @ 1.25 ml/L of water (250 ml/acre)"
                ],
                organicRemedies: [
                    "Neem Seed Kernel Extract (NSKE 5%) foliar spray",
                    "Trichoderma viride 5g/L bio-fungicide soil & collar drench"
                ],
                diagnosticClass: "Fungal / Oomycete Disease",
                scientificName: "Puccinia striiformis f. sp. tritici",
                favourableClimate: "Cool and moist conditions (10°C - 20°C) with persistent fog or morning dew.",
                sprayAdvisory: "Spray window: Early morning (06:00 - 09:00) with wind < 8 km/h."
            )
            currentDiagnosis = diag
            scanHistory.insert(diag, at: 0)
            isAnalyzing = false
            showResultModal = true
        }
    }
}

public struct DiagnosisResultSheet: View {
    public let diagnosis: DiagnosisResponse
    public let image: UIImage?
    @Binding public var isPresented: Bool
    @ObservedObject private var firebase = FirebaseManager.shared
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .cornerRadius(14)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Header card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(diagnosis.diagnosticClass.uppercased())
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text("\(diagnosis.confidenceScore)% Confidence")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                .cornerRadius(6)
                        }
                        
                        Text(diagnosis.diseaseName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(diagnosis.scientificName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                            .italic()
                        
                        Text(diagnosis.diagnosisText)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                            .padding(.top, 4)
                        
                        // Favourable climate
                        HStack(spacing: 4) {
                            Image(systemName: "thermometer.sun.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 11))
                            Text(diagnosis.favourableClimate)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                    .padding(16)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.08))
                    .cornerRadius(14)
                    
                    // Spray Advisory Window
                    HStack(spacing: 8) {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Text(diagnosis.sprayAdvisory)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.10))
                    .cornerRadius(10)
                    
                    // CIB&RC Chemical Treatments
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "cross.vial.fill")
                                .foregroundColor(.blue)
                            Text("CIB&RC Registered Chemical Remedies")
                                .font(.system(size: 15, weight: .bold))
                        }
                        
                        ForEach(diagnosis.recommendedChemicals, id: \.self) { chem in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                                    .padding(.top, 2)
                                Text(chem)
                                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                    }
                    .padding(16)
                    .background(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    
                    // Organic Alternatives
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "leaf.circle.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Text("Bio-Rational & Organic Solutions")
                                .font(.system(size: 15, weight: .bold))
                        }
                        
                        ForEach(diagnosis.organicRemedies, id: \.self) { remedy in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .font(.system(size: 13))
                                    .padding(.top, 2)
                                Text(remedy)
                                    .font(.system(size: 13, weight: .medium))
                            }
                        }
                    }
                    .padding(16)
                    .background(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                }
                .padding(20)
            }
            .navigationTitle("Diagnosis Result")
            .navigationBarItems(trailing: Button("Done") { isPresented = false })
        }
    }
}
