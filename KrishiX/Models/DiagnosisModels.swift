import Foundation

public struct DiagnosisResponse: Codable, Equatable {
    public var success: Bool
    public var diagnosisText: String
    public var cropName: String
    public var diseaseName: String
    public var severity: String
    public var confidence: Double
    public var recommendedChemicals: [String]
    public var organicRemedies: [String]

    public var confidenceScore: Int {
        Int((confidence * 100).clamped(to: 1...100))
    }

    public init(
        success: Bool = true,
        diagnosisText: String = "",
        cropName: String = "Wheat",
        diseaseName: String = "Yellow Rust (Puccinia striiformis)",
        severity: String = "Moderate",
        confidence: Double = 0.94,
        recommendedChemicals: [String] = ["Propiconazole 25% EC @ 1ml/L", "Tebuconazole 25.9% EC @ 1.25ml/L"],
        organicRemedies: [String] = ["Neem Seed Kernel Extract (NSKE 5%)", "Trichoderma viride 5g/L bio-fungicide"]
    ) {
        self.success = success
        self.diagnosisText = diagnosisText
        self.cropName = cropName
        self.diseaseName = diseaseName
        self.severity = severity
        self.confidence = confidence
        self.recommendedChemicals = recommendedChemicals
        self.organicRemedies = organicRemedies
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public struct ChemicalIngredient: Identifiable, Equatable {
    public var id: String { name }
    public var name: String
    public var type: String
    public var modeOfAction: String
    public var targetDiseases: String
    public var cibrcDosage: String
    public var fracIracCode: String
}

public struct TankMixRule: Identifiable, Equatable {
    public var id: String { "\(chemA)+\(chemB)" }
    public var chemA: String
    public var chemB: String
    public var isCompatible: Bool
    public var advisory: String
}

public struct CropScienceData {
    public static let chemicals: [ChemicalIngredient] = [
        ChemicalIngredient(
            name: "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
            type: "Fungicide (Broad Spectrum)",
            modeOfAction: "FRAC 11 (QoI) + FRAC 3 (DMI)",
            targetDiseases: "Early Blight, Late Blight, Anthracnose, Powdery Mildew",
            cibrcDosage: "1.0 ml per Litre of water (200 ml/acre)",
            fracIracCode: "FRAC 11 + 3"
        ),
        ChemicalIngredient(
            name: "Chlorantraniliprole 18.5% SC",
            type: "Insecticide (Diamide)",
            modeOfAction: "IRAC 28 (Ryanodine Receptor Modulator)",
            targetDiseases: "Stem Borer, Leaf Folder, Fruit Borer, DBM",
            cibrcDosage: "0.3 - 0.4 ml per Litre of water (60 ml/acre)",
            fracIracCode: "IRAC 28"
        ),
        ChemicalIngredient(
            name: "Mancozeb 75% WP",
            type: "Contact Protectant Fungicide",
            modeOfAction: "FRAC M03 (Multi-site activity)",
            targetDiseases: "Leaf spots, Damping off, Downy Mildew, Rusts",
            cibrcDosage: "2.0 - 2.5 g per Litre of water (500g/acre)",
            fracIracCode: "FRAC M03"
        ),
        ChemicalIngredient(
            name: "Emamectin Benzoate 5% SG",
            type: "Bio-rational Insecticide",
            modeOfAction: "IRAC 6 (Glutamate-gated chloride channel allosteric modulators)",
            targetDiseases: "Bollworm, Pod Borer, Spodoptera, Thrips",
            cibrcDosage: "0.5 g per Litre of water (80-100 g/acre)",
            fracIracCode: "IRAC 6"
        )
    ]

    public static let tankMixRules: [TankMixRule] = [
        TankMixRule(
            chemA: "Mancozeb 75% WP",
            chemB: "Chlorantraniliprole 18.5% SC",
            isCompatible: true,
            advisory: "Fully compatible. Prepare slurry of WP in water first before adding SC formulation."
        ),
        TankMixRule(
            chemA: "Copper Oxychloride 50% WP",
            chemB: "Organophosphate / Emulsifiable Concentrates (EC)",
            isCompatible: false,
            advisory: "Incompatible! High alkaline pH causes severe chemical hydrolysis and phytotoxicity burns."
        ),
        TankMixRule(
            chemA: "Azoxystrobin + Difenoconazole",
            chemB: "Chelated Micronutrients (Zinc/Boron)",
            isCompatible: true,
            advisory: "Compatible if pH of spray water is between 6.0 and 7.0."
        )
    ]
}
