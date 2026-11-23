import SwiftUI

public struct GuideView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedGuideTab: Int = 0
    @State private var selectedCropFilter: String = "All"
    @State private var diseaseSearchQuery: String = ""
    @State private var expandedDiseaseId: String? = nil
    
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
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
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
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            // Sub-tabs: Crop Pathology | Tank-Mix & WALES | Active Ingredients
            HStack(spacing: 0) {
                tabButton(title: "Crop Pathology", index: 0)
                tabButton(title: "Tank-Mix (WALES)", index: 1)
                tabButton(title: "CIB&RC Actives", index: 2)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.12, green: 0.13, blue: 0.15) : Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    if selectedGuideTab == 0 {
                        pathologyDirectoryContent
                    } else if selectedGuideTab == 1 {
                        tankMixAndWalesContent
                    } else {
                        activeIngredientsContent
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
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
            }
            
            // Disease Cards
            ForEach(filteredDiseases) { disease in
                diseaseCard(disease: disease)
            }
        }
    }
    
    private func diseaseCard(disease: CropDiseaseItem) -> some View {
        let isExpanded = expandedDiseaseId == disease.id
        
        return VStack(alignment: .leading, spacing: 10) {
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
                
                Button(action: {
                    withAnimation {
                        expandedDiseaseId = isExpanded ? nil : disease.id
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
            }
            
            // Favourable Climate
            HStack(spacing: 4) {
                Image(systemName: "thermometer.sun.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 11))
                Text(disease.favourableClimate)
                    .font(.system(size: 11))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.3, green: 0.3, blue: 0.3))
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().padding(.vertical, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DIAGNOSTIC SYMPTOMS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Text(disease.symptoms)
                            .font(.system(size: 12))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.9) : Color(red: 0.18, green: 0.20, blue: 0.22))
                            .lineSpacing(2)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CIB&RC MANAGEMENT & DOSAGE")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.blue)
                        Text(disease.management)
                            .font(.system(size: 12))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.9) : Color(red: 0.18, green: 0.20, blue: 0.22))
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - 2. Tank-Mix & WALES Mixing Order Content
    private var tankMixAndWalesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Tank-Mix Simulator")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            VStack(spacing: 12) {
                HStack {
                    Text("Chemical 1:")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 85, alignment: .leading)
                    Picker("", selection: $selectedChemA) {
                        ForEach(chemicalNames, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("Chemical 2:")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 85, alignment: .leading)
                    Picker("", selection: $selectedChemB) {
                        ForEach(chemicalNames, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
            )
            
            // Compatibility Result
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
                    .fill((compatible ? Color(red: 0.13, green: 0.55, blue: 0.28) : Color.red).opacity(0.12))
            )
            
            // Standard WALES Mixing Order Guide
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "list.number")
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    Text("Standard WALES Tank Mixing Order")
                        .font(.system(size: 15, weight: .bold))
                }
                
                ForEach(CropScienceData.walesSteps) { step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .frame(width: 32, height: 32)
                            Text(step.letter)
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(step.title)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                                Spacer()
                                Text(step.category)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            Text(step.action)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                    )
                }
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - 3. CIB&RC Actives Content
    private var activeIngredientsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CIB&RC Registered Active Ingredients")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            ForEach(CropScienceData.chemicals) { chem in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(chem.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Spacer()
                        Text(chem.fracIracCode)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    Text("Type: \(chem.type)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                    
                    Text("Target Diseases/Pests: \(chem.targetDiseases)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .font(.system(size: 11))
                        Text("Recommended Dosage: \(chem.cibrcDosage)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                )
            }
        }
    }
}
