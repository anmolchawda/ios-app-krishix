import SwiftUI

public struct GuideView: View {
    public var onOpenDrawer: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedGuideTab: Int = 0
    @State private var selectedCropFilter: String = "All"
    @State private var diseaseSearchQuery: String = ""
    @State private var selectedDiseaseForModal: CropDiseaseItem? = nil
    
    // Tank Mix State
    @State private var selectedChemA: String = "Mancozeb 75% WP"
    @State private var selectedChemB: String = "Chlorantraniliprole 18.5% SC"
    
    let cropFilters = ["All", "Tomato", "Wheat", "Brinjal", "Onion"]
    let chemicalNames = [
        "Mancozeb 75% WP",
        "Chlorantraniliprole 18.5% SC",
        "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
        "Emamectin Benzoate 5% SG",
        "Propiconazole 25% EC",
        "Copper Oxychloride 50% WP",
        "Neem Oil 10,000 ppm"
    ]
    
    public init(onOpenDrawer: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
        self.onBack = onBack
    }
    
    var filteredDiseases: [CropDiseaseItem] {
        CropScienceData.diseases.filter { item in
            let matchesCrop = selectedCropFilter == "All" || item.cropName.caseInsensitiveCompare(selectedCropFilter) == .orderedSame
            let matchesSearch = diseaseSearchQuery.isEmpty ||
                item.name.localizedCaseInsensitiveContains(diseaseSearchQuery) ||
                item.symptoms.localizedCaseInsensitiveContains(diseaseSearchQuery) ||
                item.scientificName.localizedCaseInsensitiveContains(diseaseSearchQuery)
            return matchesCrop && matchesSearch
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar with Back Button navigating to Feed (Requirement 13)
            KrishiTopBar(
                onOpenDrawer: onOpenDrawer,
                showBackButton: true,
                onBack: onBack
            )
            
            // Sub-tabs: Crop Pathology | Tank-Mix (WALES) | Formulations & Risks
            HStack(spacing: 0) {
                tabButton(title: "Crop Pathology", index: 0)
                tabButton(title: "Tank-Mix (WALES)", index: 1)
                tabButton(title: "Formulations & Incompatibilities", index: 2)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.12, green: 0.13, blue: 0.15) : Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    if selectedGuideTab == 0 {
                        pathologyDirectoryContent
                    } else if selectedGuideTab == 1 {
                        tankMixSimulatorContent
                    } else {
                        formulationsAndIncompatibilitiesContent
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
        .sheet(item: $selectedDiseaseForModal) { disease in
            DiseaseDetailLandingModal(disease: disease, isPresented: Binding(
                get: { selectedDiseaseForModal != nil },
                set: { if !$0 { selectedDiseaseForModal = nil } }
            ))
        }
    }
    
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedGuideTab = index }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: selectedGuideTab == index ? .bold : .medium))
                    .foregroundColor(selectedGuideTab == index ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
                
                Rectangle()
                    .fill(selectedGuideTab == index ? Color(red: 0.13, green: 0.55, blue: 0.28) : Color.clear)
                    .frame(height: 3)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 1. Pathology Directory Content
    private var pathologyDirectoryContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search crop diseases, symptoms, pathogens...", text: $diseaseSearchQuery)
                    .font(.system(size: 14))
                    .foregroundColor(firebase.isDarkTheme ? .white : .black)
                if !diseaseSearchQuery.isEmpty {
                    Button(action: { diseaseSearchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .cornerRadius(10)
            
            // Crop Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(cropFilters, id: \.self) { crop in
                        Button(action: { selectedCropFilter = crop }) {
                            Text(crop)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(selectedCropFilter == crop ? .white : Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedCropFilter == crop ?
                                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                                    (firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color.white)
                                )
                                .cornerRadius(14)
                        }
                    }
                }
            }
            
            // Directory Count
            HStack {
                Text("Clinical Pathology Directory (\(filteredDiseases.count))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                Spacer()
                Text("Tap card for full clinical report")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            // Disease Cards (Clickable to open DiseaseDetailLandingModal matching frame_04_12.3s.jpg)
            ForEach(filteredDiseases) { disease in
                Button(action: {
                    selectedDiseaseForModal = disease
                }) {
                    diseaseCard(disease: disease)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func diseaseCard(disease: CropDiseaseItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(disease.cropName)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                            .cornerRadius(4)
                        
                        Text(disease.category)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.10))
                            .cornerRadius(4)
                    }
                    
                    Text(disease.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                        .padding(.top, 2)
                    
                    Text(disease.scientificName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .italic()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
            
            HStack(spacing: 4) {
                Image(systemName: "thermometer.sun.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 11))
                Text(disease.favourableClimate)
                    .font(.system(size: 11))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.3, green: 0.3, blue: 0.3))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - 2. Tank-Mix Simulator Content (Matching Video frame_06_18.4s.jpg)
    private var tankMixSimulatorContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Tank-Mix Simulator")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            // Dual Beaker Graphic & Selector
            HStack(spacing: 16) {
                // Tank A Beaker
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.13, green: 0.55, blue: 0.28), lineWidth: 2)
                            .frame(height: 100)
                        
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                .frame(height: 60)
                        }
                        .padding(4)
                        
                        Text("Tank A")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    
                    Picker("Chemical 1", selection: $selectedChemA) {
                        ForEach(chemicalNames, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                
                // Tank B Beaker
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(height: 100)
                        
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                .frame(height: 50)
                        }
                        .padding(4)
                        
                        Text("Tank B")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    
                    Picker("Chemical 2", selection: $selectedChemB) {
                        ForEach(chemicalNames, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
            )
            
            // Compatibility Result Card
            let isSame = selectedChemA == selectedChemB
            let isMatch = CropScienceData.tankMixRules.first {
                ($0.chemA == selectedChemA && $0.chemB == selectedChemB) ||
                ($0.chemA == selectedChemB && $0.chemB == selectedChemA)
            }
            let compatible = isSame || (isMatch?.isCompatible ?? true)
            let advisoryText = isSame ? "Identical chemical. No mixing incompatibility." : (isMatch?.advisory ?? "Physically and chemically compatible. Maintain proper dilution with clean spray water.")
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: compatible ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(compatible ? Color(red: 0.13, green: 0.55, blue: 0.28) : .red)
                        .font(.system(size: 20))
                    
                    Text(compatible ? "Compatible Tank Combination" : "Incompatible - Do Not Mix")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(compatible ? Color(red: 0.13, green: 0.55, blue: 0.28) : .red)
                }
                
                Text(advisoryText)
                    .font(.system(size: 13))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                    .lineSpacing(2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(compatible ? Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.08) : Color.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(compatible ? Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // WALES Mixing Order Section (Matching frame_06_18.4s.jpg)
            Text("Standard Tank Mixing Sequence (WALES Rule)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                .padding(.top, 8)
            
            VStack(spacing: 10) {
                ForEach(CropScienceData.walesSteps) { step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 32, height: 32)
                            Text(step.letter)
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                            Text(step.action)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    )
                }
            }
        }
    }
    
    // MARK: - 3. Formulations & Critical Chemical Class Incompatibilities (Matching frames 07 & 09)
    private var formulationsAndIncompatibilitiesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Critical Incompatibilities Section (Matching frame_09_27.6s.jpg)
            Text("Critical Chemical Class Incompatibilities")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                incompatibilityCard(
                    combo: "Thiophanate Methyl + Copper Fungicides",
                    warning: "STRICTLY DO NOT MIX WITH",
                    reason: "Alkaline bond cleavage breaks down active ingredient and destroys biological efficacy."
                )
                incompatibilityCard(
                    combo: "Sulfur + Neem Oil / Any Crop Spray Oil",
                    warning: "STRICTLY DO NOT MIX WITH",
                    reason: "Oil acts as penetrant causing acute phytotoxic foliar scorching and massive defoliation in temperatures > 28°C."
                )
                incompatibilityCard(
                    combo: "Bio-Fungicides (Trichoderma) + Chemical Fungicides",
                    warning: "STRICTLY DO NOT MIX WITH",
                    reason: "Chemical active ingredients kill living beneficial fungal spores in the spray tank instantaneously."
                )
            }
            
            // Formulations Directory (Matching frame_07_21.5s.jpg)
            Text("Pesticide Formulations Directory")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                .padding(.top, 10)
            
            VStack(spacing: 12) {
                ForEach(CropScienceData.formulations) { form in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(form.code)
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .cornerRadius(6)
                            
                            Text(form.fullName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                            
                            Spacer()
                            
                            Text("Rank #\(form.mixingOrderRank)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        Text(form.description)
                            .font(.system(size: 12))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                        
                        HStack(alignment: .top, spacing: 4) {
                            Text("⚠️ Risk:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                            Text(form.physicalRisk)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                    )
                }
            }
        }
    }
    
    private func incompatibilityCard(combo: String, warning: String, reason: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(warning)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(4)
                
                Spacer()
            }
            
            Text(combo)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
            
            Text(reason)
                .font(.system(size: 12))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
                .lineSpacing(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

// MARK: - Disease Detail Landing Modal (Matching Video frame_04_12.3s.jpg)
public struct DiseaseDetailLandingModal: View {
    public let disease: CropDiseaseItem
    @Binding public var isPresented: Bool
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @State private var selectedPhotoIndex: Int = 0
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header Banner with Symptom Photos Carousel
                    VStack(alignment: .leading, spacing: 8) {
                        TabView(selection: $selectedPhotoIndex) {
                            symptomSlide(title: "1. Primary Symptom Lesion", index: 0)
                                .tag(0)
                            symptomSlide(title: "2. Field Damage & Progression", index: 1)
                                .tag(1)
                        }
                        .frame(height: 200)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .cornerRadius(14)
                    }
                    
                    // Disease Title & Scientific Name
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(disease.cropName)
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12))
                                .cornerRadius(6)
                            
                            Text(disease.category)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.12))
                                .cornerRadius(6)
                        }
                        
                        Text(disease.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                        
                        Text(disease.scientificName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                    Divider()
                    
                    // Causing Agent Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CAUSING PATHOGEN / AGENT")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Text(disease.causingAgent)
                            .font(.system(size: 14))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                    }
                    
                    // Favourable Climate Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("FAVOURABLE CLIMATE & CONDITIONS")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.orange)
                        Text(disease.favourableClimate)
                            .font(.system(size: 14))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                    }
                    
                    // Symptoms Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DIAGNOSTIC FIELD SYMPTOMS")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.purple)
                        Text(disease.symptoms)
                            .font(.system(size: 14))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                            .lineSpacing(3)
                    }
                    
                    // Management & Dosages Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CIB&RC MANAGEMENT & SPRAY DOSAGES")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.blue)
                        Text(disease.management)
                            .font(.system(size: 14))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                            .lineSpacing(3)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Clinical Disease Details")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
    
    private func symptomSlide(title: String, index: Int) -> some View {
        ZStack(alignment: .bottomLeading) {
            Color(red: 0.18, green: 0.22, blue: 0.20)
            
            VStack {
                Spacer()
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.8))
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.55))
                .cornerRadius(8)
                .padding(12)
        }
    }
}
