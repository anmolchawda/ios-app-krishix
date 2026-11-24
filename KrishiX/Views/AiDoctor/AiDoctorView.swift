import SwiftUI
import UIKit

public struct AiDoctorView: View {
    public var onOpenDrawer: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var scansLeft: Int = 10
    @State private var showCropSelectionModal: Bool = false
    @State private var pendingSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedCropName: String = "Brinjal"
    
    @State private var showCameraPicker: Bool = false
    @State private var showGalleryPicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    
    @State private var isAnalyzing: Bool = false
    @State private var chainOfThoughtStep: Int = 0
    @State private var showResultModal: Bool = false
    @State private var currentDiagnosis: DiagnosisResponse? = nil
    @State private var scanHistory: [DiagnosisResponse] = []
    
    public init(onOpenDrawer: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
        self.onBack = onBack
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Back Button navigating to Feed (Requirement 13)
            KrishiTopBar(
                onOpenDrawer: onOpenDrawer,
                showBackButton: true,
                onBack: onBack
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Top banner: Scans Available / Top up
                    scansAlertBanner
                    
                    // Card: Take Crop Photo to Diagnose
                    takePhotoCard
                    
                    // Scan History / Last Scans Section
                    lastScansSection
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
        .sheet(isPresented: $showCropSelectionModal) {
            // Crop Selection Modal (Matching Video frame_12_36.8s.jpg)
            CropSelectionModal(
                selectedCrop: $selectedCropName,
                isPresented: $showCropSelectionModal,
                onProceed: {
                    if pendingSourceType == .camera {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCameraPicker = true
                        } else {
                            // On simulator or if camera hardware restricted, open photo library
                            showGalleryPicker = true
                        }
                    } else {
                        showGalleryPicker = true
                    }
                }
            )
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
                // Structured Diagnostic Results Sheet (Matching Video frame_10_30.7s.jpg)
                UnifiedDiagnosticResultsSheet(
                    diagnosis: diag,
                    scannedImage: selectedImage,
                    isPresented: $showResultModal
                )
            }
        }
    }
    
    // MARK: - Scans Alert Banner
    private var scansAlertBanner: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
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
                Image(systemName: "cross.case.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 18))
                
                Text(translation.getString("takePhotoDiagnose"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            Text("Diagnose leaf diseases, pests, nutritional deficiencies, and chemical burns with clinical accuracy.")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(2)
            
            if isAnalyzing {
                chainOfThoughtProgressView
            } else {
                HStack(spacing: 12) {
                    // Camera Button: Opens Crop Selection Modal First (Video frame_12)
                    Button(action: {
                        pendingSourceType = .camera
                        showCropSelectionModal = true
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
                    
                    // Gallery Button: Opens Crop Selection Modal First (Video frame_12)
                    Button(action: {
                        pendingSourceType = .photoLibrary
                        showCropSelectionModal = true
                    }) {
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
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Chain of Thought Progress View
    private var chainOfThoughtProgressView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.13, green: 0.55, blue: 0.28)))
                Text("Analyzing Crop Foliage with Clinical CoT...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                cotStepRow(step: 1, title: "1. Visual Breakdown: Inspecting foliar symptoms & lesions")
                cotStepRow(step: 2, title: "2. Differential Audit: Chemical scorch & abiotic stress")
                cotStepRow(step: 3, title: "3. Micro-climate & Latent Pathogen Integration")
                cotStepRow(step: 4, title: "4. Actionable 3-Tier IPM Formulation")
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.06))
        .cornerRadius(12)
    }
    
    private func cotStepRow(step: Int, title: String) -> some View {
        HStack(spacing: 8) {
            if chainOfThoughtStep > step {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 14))
            } else if chainOfThoughtStep == step {
                Circle()
                    .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .frame(width: 14, height: 14)
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 14, height: 14)
            }
            
            Text(title)
                .font(.system(size: 12, weight: chainOfThoughtStep == step ? .bold : .regular))
                .foregroundColor(chainOfThoughtStep >= step ? (firebase.isDarkTheme ? .white : Color.black) : .gray)
        }
    }
    
    // MARK: - Last Scans Section
    private var lastScansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(translation.getString("lastScans"))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            if scanHistory.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 34))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(translation.getString("noRecentScans"))
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                )
            } else {
                ForEach(scanHistory, id: \.diseaseName) { scan in
                    Button(action: {
                        currentDiagnosis = scan
                        showResultModal = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(scan.cropName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                                Text(scan.diseaseName)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("\(scan.confidenceScore)%")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                .cornerRadius(8)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func handleImageSelected(_ image: UIImage) {
        self.selectedImage = image
        self.isAnalyzing = true
        self.chainOfThoughtStep = 1
        
        // Step progression animation
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            self.chainOfThoughtStep = 2
        }
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
            self.chainOfThoughtStep = 3
        }
        Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { _ in
            self.chainOfThoughtStep = 4
        }
        
        // Sync with Firebase Callable Function 'diagnoseCrop'
        firebase.diagnoseCropDisease(
            cropName: selectedCropName,
            symptoms: "Foliar spotting and lesion damage observed on \(selectedCropName)",
            image: image,
            languageCode: translation.currentLanguage
        ) { diagnosis in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                self.isAnalyzing = false
                self.currentDiagnosis = diagnosis
                self.scanHistory.insert(diagnosis, at: 0)
                if self.scansLeft > 0 { self.scansLeft -= 1 }
                self.showResultModal = true
            }
        }
    }
}

// MARK: - Crop Selection Modal (Matching Video frame_12_36.8s.jpg)
public struct CropSelectionModal: View {
    @Binding public var selectedCrop: String
    @Binding public var isPresented: Bool
    public var onProceed: () -> Void
    
    @State private var searchQuery: String = ""
    @ObservedObject private var firebase = FirebaseManager.shared
    
    let indianCrops: [(name: String, icon: String)] = [
        ("Chilli", "flame.fill"),
        ("Corn", "leaf.fill"),
        ("Cotton", "cloud.fill"),
        ("Cucumber", "circle.grid.cross.fill"),
        ("Brinjal", "oval.fill"),
        ("Tomato", "circle.fill"),
        ("Wheat", "waveform.path"),
        ("Paddy (Rice)", "drop.fill"),
        ("Soybean", "circle.hexagongrid.fill"),
        ("Mustard", "sun.max.fill"),
        ("Onion", "circle.grid.2x2.fill"),
        ("Potato", "oval.portrait.fill")
    ]
    
    var filteredCrops: [(name: String, icon: String)] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return indianCrops
        }
        return indianCrops.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Select or Enter Your Crop")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search crop (e.g. Chilli, Corn, Cotton)", text: $searchQuery)
                        .font(.system(size: 14))
                        .foregroundColor(firebase.isDarkTheme ? .white : .black)
                }
                .padding(12)
                .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.95, green: 0.96, blue: 0.97))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Crops List
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(filteredCrops, id: \.name) { crop in
                            Button(action: {
                                selectedCrop = crop.name
                                isPresented = false
                                onProceed()
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: crop.icon)
                                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                            .font(.system(size: 16))
                                    }
                                    
                                    Text(crop.name)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.96, green: 0.97, blue: 0.98))
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

// MARK: - Unified Diagnostic Results Sheet (Matching Video frame_10_30.7s.jpg)
public struct UnifiedDiagnosticResultsSheet: View {
    public let diagnosis: DiagnosisResponse
    public let scannedImage: UIImage?
    @Binding public var isPresented: Bool
    
    @ObservedObject private var firebase = FirebaseManager.shared
    
    @State private var isTier1Expanded: Bool = true
    @State private var isTier2Expanded: Bool = true
    @State private var isTier3Expanded: Bool = true
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header Banner with Confidence Badge
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(diagnosis.cropName)
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                    .cornerRadius(6)
                                
                                Text(diagnosis.diagnosticClass)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.12))
                                    .cornerRadius(6)
                            }
                            
                            Text(diagnosis.diseaseName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                            
                            Text(diagnosis.scientificName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .italic()
                        }
                        
                        Spacer()
                        
                        // Confidence Badge
                        VStack(spacing: 2) {
                            Text("\(diagnosis.confidenceScore)%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            Text("CONFIDENCE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                        .cornerRadius(10)
                    }
                    
                    // Scanned Leaf Photo Preview if available
                    if let img = scannedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    }
                    
                    // Differential Diagnosis Card (Matching frame_10: "But it might also be: Phomopsis Fruit, Fruit Anthracnose")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DIFFERENTIAL DIAGNOSIS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.orange)
                        
                        HStack(spacing: 6) {
                            Text("Alternative Possibilities:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                            
                            Text(diagnosis.differentialAlternatives.joined(separator: ", "))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Step 1: Visual Breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STEP 1: VISUAL BREAKDOWN")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        
                        bulletPoint(title: "Symptoms", text: diagnosis.symptomsObserved)
                        bulletPoint(title: "Lesion Margins", text: diagnosis.lesionMargins)
                        bulletPoint(title: "Pests / Organisms", text: diagnosis.pestsOrganisms)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    )
                    
                    // Step 2: Field Factor Context & Abiotic Stress
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STEP 2: FIELD FACTOR INTEGRATION")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.blue)
                        
                        bulletPoint(title: "Abiotic Stress", text: diagnosis.abioticStress)
                        bulletPoint(title: "Micro-climate Risk", text: diagnosis.microclimateRisk)
                        bulletPoint(title: "Nutritional Lockout", text: diagnosis.nutritionalLockout)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    )
                    
                    // Step 3: Differential Elimination (Ruled Out)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("STEP 3: DIFFERENTIAL ELIMINATION SCORE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.purple)
                        
                        bulletPoint(title: "Ruled Out", text: diagnosis.ruledOutPathogens)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    )
                    
                    // Step 4: Actionable 3-Tier IPM Management Plan (Collapsible accordions)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("STEP 4: ACTIONABLE 3-TIER IPM PLAN")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        
                        // Tier 1: Cultural & Sanitation
                        ipmAccordion(
                            title: "Tier 1: Cultural & Sanitation Controls",
                            color: .green,
                            isExpanded: $isTier1Expanded,
                            items: diagnosis.culturalControls
                        )
                        
                        // Tier 2: Biological & Biorational Tactics
                        ipmAccordion(
                            title: "Tier 2: Biological & Biorational Tactics",
                            color: .teal,
                            isExpanded: $isTier2Expanded,
                            items: diagnosis.biologicalTactics
                        )
                        
                        // Tier 3: Targeted Remediation / Chemical Control
                        ipmAccordion(
                            title: "Tier 3: Targeted Remediation / Chemical Control",
                            color: .blue,
                            isExpanded: $isTier3Expanded,
                            items: diagnosis.chemicalRemediation
                        )
                    }
                }
                .padding(20)
            }
            .navigationTitle("Diagnostic Report")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
    
    private func bulletPoint(title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            Text("\(title):")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.35, green: 0.38, blue: 0.42))
        }
    }
    
    private func ipmAccordion(title: String, color: Color, isExpanded: Binding<Bool>, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation { isExpanded.wrappedValue.toggle() }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .foregroundColor(color)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            
            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: 6) {
                            Text("✓")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(color)
                            Text(item)
                                .font(.system(size: 12))
                                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.9) : Color(red: 0.20, green: 0.22, blue: 0.25))
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(color.opacity(0.07))
        .cornerRadius(10)
    }
}
