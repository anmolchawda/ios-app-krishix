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
    public var diagnosticClass: String
    public var scientificName: String
    public var favourableClimate: String
    public var sprayAdvisory: String

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
        organicRemedies: [String] = ["Neem Seed Kernel Extract (NSKE 5%)", "Trichoderma viride 5g/L bio-fungicide"],
        diagnosticClass: String = "Fungal / Oomycete Disease",
        scientificName: String = "Puccinia striiformis f. sp. tritici",
        favourableClimate: String = "Cool and moist conditions (10°C - 20°C) with persistent fog or morning dew.",
        sprayAdvisory: String = "Ideal spraying window: Early morning before wind speed exceeds 10 km/h."
    ) {
        self.success = success
        self.diagnosisText = diagnosisText
        self.cropName = cropName
        self.diseaseName = diseaseName
        self.severity = severity
        self.confidence = confidence
        self.recommendedChemicals = recommendedChemicals
        self.organicRemedies = organicRemedies
        self.diagnosticClass = diagnosticClass
        self.scientificName = scientificName
        self.favourableClimate = favourableClimate
        self.sprayAdvisory = sprayAdvisory
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public struct CropDiseaseItem: Identifiable, Codable, Equatable {
    public var id: String
    public var cropName: String
    public var name: String
    public var scientificName: String
    public var category: String
    public var causingAgent: String
    public var favourableClimate: String
    public var symptoms: String
    public var management: String
    public var imageUrl: String
    
    public init(
        id: String,
        cropName: String,
        name: String,
        scientificName: String,
        category: String,
        causingAgent: String,
        favourableClimate: String,
        symptoms: String,
        management: String,
        imageUrl: String = ""
    ) {
        self.id = id
        self.cropName = cropName
        self.name = name
        self.scientificName = scientificName
        self.category = category
        self.causingAgent = causingAgent
        self.favourableClimate = favourableClimate
        self.symptoms = symptoms
        self.management = management
        self.imageUrl = imageUrl
    }
}

public struct WalesStep: Identifiable, Equatable {
    public var id: String { letter }
    public var letter: String
    public var title: String
    public var category: String
    public var action: String
}

public struct FormulationType: Identifiable, Equatable {
    public var id: String { code }
    public var code: String
    public var fullName: String
    public var category: String
    public var mixingOrderRank: Int
    public var description: String
    public var agitationAdvice: String
    public var jarTestGuidance: String
    public var physicalRisk: String
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
    public static let walesSteps: [WalesStep] = [
        WalesStep(letter: "W", title: "Wettable Powders & Dry Granules", category: "WP / WDG", action: "Fill tank 50% with water. Start agitator. Add pre-slurried WP/WDG and allow full dissolution for 3-5 minutes."),
        WalesStep(letter: "A", title: "Agitate Tank Continuously", category: "Agitation", action: "Keep mechanical or hydraulic bypass agitation running constantly to prevent caking at bottom."),
        WalesStep(letter: "L", title: "Liquid Flowables & Suspensions", category: "SC / CS / F", action: "Add suspension concentrates slowly. Ensure steady dispersion without foaming."),
        WalesStep(letter: "E", title: "Emulsifiable Concentrates", category: "EC / EW", action: "Add oil-based concentrates. Observe for milky blooming without curdling or oil separation."),
        WalesStep(letter: "S", title: "Soluble Liquids & Adjuvants", category: "SL / SP / Non-ionic Surfactants", action: "Add water-soluble formulations and crop spray oils last. Top off tank to full volume.")
    ]

    public static let formulations: [FormulationType] = [
        FormulationType(
            code: "WP",
            fullName: "Wettable Powder",
            category: "Dry / Solid",
            mixingOrderRank: 2,
            description: "Dry finely milled powder with wetting agents. Forms physical suspension in water.",
            agitationAdvice: "Requires vigorous continuous agitation. Pre-slurry in a separate bucket.",
            jarTestGuidance: "Mix 5g in 500ml water. Ensure no sediment cakes after 15 min.",
            physicalRisk: "Can coagulate into sludge if added after EC formulations."
        ),
        FormulationType(
            code: "WDG",
            fullName: "Water Dispersible Granules",
            category: "Dry / Solid",
            mixingOrderRank: 2,
            description: "Granulated powder that disintegrates rapidly in water with low dust hazard.",
            agitationAdvice: "Needs active agitation until completely dissolved before adding liquids.",
            jarTestGuidance: "Shake in 500ml water. Granules must dissolve within 60 seconds.",
            physicalRisk: "Cold water (<12°C) slows dissolution; pre-dissolve in lukewarm water."
        ),
        FormulationType(
            code: "SC",
            fullName: "Suspension Concentrate",
            category: "Liquid / Flowable",
            mixingOrderRank: 3,
            description: "Solid active ingredient suspended in liquid medium.",
            agitationAdvice: "Shake container before pouring. Maintain medium agitation.",
            jarTestGuidance: "Mix 5ml in 500ml water. Check for uniform cloudy suspension.",
            physicalRisk: "Extreme pH (<5 or >8.5) can cause flocculation."
        ),
        FormulationType(
            code: "EC",
            fullName: "Emulsifiable Concentrate",
            category: "Oil / Emulsion",
            mixingOrderRank: 4,
            description: "Active ingredient dissolved in organic solvent with emulsifiers.",
            agitationAdvice: "Pour slowly into agitated tank. Bloom should turn milky white immediately.",
            jarTestGuidance: "Mix 5ml in 500ml water. Look for oil droplets or cream layer on top.",
            physicalRisk: "Mixing with micronutrients (Zinc/Iron) can cause emulsion inversion and scorching."
        ),
        FormulationType(
            code: "SL",
            fullName: "Soluble Liquid Concentrate",
            category: "Liquid Solution",
            mixingOrderRank: 5,
            description: "Clear liquid that completely dissolves in water forming true solution.",
            agitationAdvice: "Gentle agitation. Add toward the end of tank fill.",
            jarTestGuidance: "Clear transparent mixture without turbidity.",
            physicalRisk: "High salt index; do not mix concentrated fertilizers directly with SL."
        )
    ]

    public static let chemicals: [ChemicalIngredient] = [
        ChemicalIngredient(
            name: "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
            type: "Fungicide (Broad Spectrum)",
            modeOfAction: "FRAC 11 (QoI) + FRAC 3 (DMI)",
            targetDiseases: "Early Blight, Late Blight, Anthracnose, Powdery Mildew, Rusts",
            cibrcDosage: "1.0 ml per Litre of water (200 ml/acre)",
            fracIracCode: "FRAC 11 + 3"
        ),
        ChemicalIngredient(
            name: "Chlorantraniliprole 18.5% SC",
            type: "Insecticide (Diamide)",
            modeOfAction: "IRAC 28 (Ryanodine Receptor Modulator)",
            targetDiseases: "Stem Borer, Leaf Folder, Fruit & Shoot Borer, DBM",
            cibrcDosage: "0.3 - 0.4 ml per Litre of water (60 ml/acre)",
            fracIracCode: "IRAC 28"
        ),
        ChemicalIngredient(
            name: "Mancozeb 75% WP",
            type: "Contact Protectant Fungicide",
            modeOfAction: "FRAC M03 (Multi-site activity)",
            targetDiseases: "Leaf spots, Damping off, Downy Mildew, Rusts, Early Blight",
            cibrcDosage: "2.0 - 2.5 g per Litre of water (500g/acre)",
            fracIracCode: "FRAC M03"
        ),
        ChemicalIngredient(
            name: "Emamectin Benzoate 5% SG",
            type: "Bio-rational Insecticide",
            modeOfAction: "IRAC 6 (Glutamate-gated chloride channel)",
            targetDiseases: "Bollworm, Pod Borer, Spodoptera, Thrips, Fruit Borer",
            cibrcDosage: "0.5 g per Litre of water (80-100 g/acre)",
            fracIracCode: "IRAC 6"
        ),
        ChemicalIngredient(
            name: "Propiconazole 25% EC",
            type: "Systemic Triazole Fungicide",
            modeOfAction: "FRAC 3 (Sterol biosynthesis inhibitor)",
            targetDiseases: "Yellow Rust, Brown Rust, Sheath Blight, Karnal Bunt",
            cibrcDosage: "1.0 ml per Litre of water (200 ml/acre)",
            fracIracCode: "FRAC 3"
        ),
        ChemicalIngredient(
            name: "Copper Oxychloride 50% WP",
            type: "Inorganic Copper Fungicide/Bactericide",
            modeOfAction: "FRAC M01 (Multi-site activity)",
            targetDiseases: "Bacterial Blight, Canker, Downy Mildew, Leaf Spots",
            cibrcDosage: "2.5 - 3.0 g per Litre of water (600g/acre)",
            fracIracCode: "FRAC M01"
        )
    ]

    public static let tankMixRules: [TankMixRule] = [
        TankMixRule(
            chemA: "Mancozeb 75% WP",
            chemB: "Chlorantraniliprole 18.5% SC",
            isCompatible: true,
            advisory: "Compatible: Add Mancozeb WP first with agitation until fully dissolved, then add Chlorantraniliprole SC. Ideal for early blight + fruit borer control."
        ),
        TankMixRule(
            chemA: "Copper Oxychloride 50% WP",
            chemB: "Propiconazole 25% EC",
            isCompatible: false,
            advisory: "Incompatible: Copper ions precipitate with triazole EC solvents under acidic water conditions, risking severe phytotoxicity scorch."
        ),
        TankMixRule(
            chemA: "Mancozeb 75% WP",
            chemB: "Azoxystrobin 18.2% + Difenoconazole 11.4% SC",
            isCompatible: true,
            advisory: "Compatible: Synergistic protectant + curative anti-resistance combination. Follow WALES order (WP then SC)."
        ),
        TankMixRule(
            chemA: "Emamectin Benzoate 5% SG",
            chemB: "Neem Oil 10,000 ppm",
            isCompatible: false,
            advisory: "Anti-Feedant Conflict: Neem oil creates foliar bitterness stopping insect feeding prematurely, preventing lethal ingestion of stomach-acting Emamectin Benzoate. Separate applications by 4-5 days."
        )
    ]

    public static var diseases: [CropDiseaseItem] = loadDiseasesFromCatalog()

    private static func loadDiseasesFromCatalog() -> [CropDiseaseItem] {
        if let url = Bundle.main.url(forResource: "crop_diseases_catalog", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([CropDiseaseItem].self, from: data),
           !list.isEmpty {
            return list
        }
        return defaultDiseasesFallback
    }

    public static let defaultDiseasesFallback: [CropDiseaseItem] = [
        CropDiseaseItem(
            id: "tomato_early_blight",
            cropName: "Tomato",
            name: "Early Blight (Alternaria solani)",
            scientificName: "Alternaria solani",
            category: "Fungal",
            causingAgent: "Alternaria solani fungal pathogen persisting in crop residues.",
            favourableClimate: "Warm & humid conditions (24°C - 30°C) with frequent rainfall or heavy dew.",
            symptoms: "Target board concentric rings with dark brown necrotic margins starting on lower leaves. Defoliation spreads upwards.",
            management: "Foliar spray with Mancozeb 75% WP @ 2.5g/L or Azoxystrobin + Difenoconazole SC @ 1ml/L. Remove lower infected leaves and avoid overhead irrigation."
        ),
        CropDiseaseItem(
            id: "tomato_late_blight",
            cropName: "Tomato",
            name: "Late Blight (Phytophthora infestans)",
            scientificName: "Phytophthora infestans",
            category: "Oomycete",
            causingAgent: "Phytophthora infestans water mold.",
            favourableClimate: "Cool and wet weather (10°C - 22°C) with RH > 85%.",
            symptoms: "Large, irregular water-soaked dark greasy patches with white fuzzy fungal growth on the underside during humid mornings.",
            management: "Prophylactic spray of Metalaxyl-M + Mancozeb @ 2g/L or Cymoxanil + Mancozeb. Destroy affected vine residues."
        ),
        CropDiseaseItem(
            id: "wheat_yellow_rust",
            cropName: "Wheat",
            name: "Yellow Rust (Puccinia striiformis)",
            scientificName: "Puccinia striiformis f. sp. tritici",
            category: "Fungal",
            causingAgent: "Airborne urediniospores of Puccinia striiformis.",
            favourableClimate: "Cool temperatures (10°C - 18°C) and high humidity / persistent morning fog.",
            symptoms: "Bright yellow pustules arranged in linear stripes parallel to leaf veins on flag and upper leaves. Orange-yellow dust rubs off on fingers.",
            management: "Spray Propiconazole 25% EC @ 1ml/L or Tebuconazole 25.9% EC @ 1.25ml/L at the first appearance of linear stripes."
        ),
        CropDiseaseItem(
            id: "brinjal_shoot_fruit_borer",
            cropName: "Brinjal",
            name: "Shoot and Fruit Borer (Leucinodes orbonalis)",
            scientificName: "Leucinodes orbonalis",
            category: "Insect Pest",
            causingAgent: "Larvae bore into tender shoots and developing fruits.",
            favourableClimate: "Warm & humid climate throughout vegetative and fruiting phases.",
            symptoms: "Drooping and wilting of growing shoot tips. Bore holes in fruits plugged with larval excreta.",
            management: "Clipping and destruction of wilted shoots weekly. Install pheromone traps @ 12/acre. Spray Chlorantraniliprole 18.5% SC @ 0.4ml/L or Emamectin Benzoate 5% SG @ 0.5g/L."
        ),
        CropDiseaseItem(
            id: "onion_purple_blotch",
            cropName: "Onion",
            name: "Purple Blotch (Alternaria porri)",
            scientificName: "Alternaria porri",
            category: "Fungal",
            causingAgent: "Alternaria porri fungal conidia.",
            favourableClimate: "Warm and moist weather (25°C - 30°C) with 80-90% RH.",
            symptoms: "Small, sunken, whitish flecks on leaves turning into characteristic purple-centered oval lesions with yellow halos. Leaves collapse and dry up.",
            management: "Spray Mancozeb 75% WP @ 2.5g/L with a non-ionic sticker/spreader or Difenoconazole 25% EC @ 1ml/L."
        )
    ]
}
