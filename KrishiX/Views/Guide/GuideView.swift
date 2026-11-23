import SwiftUI

public struct GuideView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedGuideTab: Int = 0
    @State private var selectedChemA: String = "Mancozeb 75% WP"
    @State private var selectedChemB: String = "Chlorantraniliprole 18.5% SC"
    
    let chemicalNames = [
        "Mancozeb 75% WP",
        "Chlorantraniliprole 18.5% SC",
        "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
        "Emamectin Benzoate 5% SG"
    ]
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            // Sub-tabs: Crop Science | Tank-Mix | Agronomy
            HStack(spacing: 0) {
                tabButton(title: "Crop Science", index: 0)
                tabButton(title: "Tank-Mix Engine", index: 1)
                tabButton(title: "Agronomy", index: 2)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.12, green: 0.13, blue: 0.15) : Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    if selectedGuideTab == 0 {
                        cropScienceContent
                    } else if selectedGuideTab == 1 {
                        tankMixContent
                    } else {
                        agronomyContent
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
    
    // MARK: - Crop Science Section
    private var cropScienceContent: some View {
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
    
    // MARK: - Tank-Mix Compatibility Engine
    private var tankMixContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tank-Mix Compatibility Engine")
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
        }
    }
    
    // MARK: - Agronomy Section
    private var agronomyContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Agronomy & Crop Management Protocols")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            agronomyCard(
                title: "Integrated Pest Management (IPM)",
                subtitle: "Threshold-based intervention strategy",
                bullets: [
                    "Deploy yellow sticky traps @ 10-15 traps/acre for early whitefly and aphid monitoring.",
                    "Spray Neem Oil 10,000 ppm (3ml/L) as first prophylactic line of defense.",
                    "Rotate FRAC groups to prevent chemical resistance buildup."
                ]
            )
            
            agronomyCard(
                title: "Fertigation & Balanced Nutrition",
                subtitle: "Nutrient management schedule",
                bullets: [
                    "Basal application: Balanced N:P:K (12:32:16) with Zinc Sulphate 10 kg/acre.",
                    "Vegetative stage: 19:19:19 foliar spray @ 5g/L during early morning.",
                    "Fruit/Pod formation: 00:00:50 (Potassium Sulphate) @ 4g/L for grain filling."
                ]
            )
        }
    }
    
    private func agronomyCard(title: String, subtitle: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(bullets, id: \.self) { b in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Text(b)
                            .font(.system(size: 12))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
}
