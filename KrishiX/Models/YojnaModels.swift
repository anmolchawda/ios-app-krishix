import Foundation

public struct YojnaScheme: Identifiable, Codable, Equatable {
    public var id: String
    public var title: String
    public var category: String
    public var description: String
    public var eligibility: String
    public var benefits: String
    public var department: String
    public var officialLink: String
    
    public init(
        id: String,
        title: String,
        category: String,
        description: String,
        eligibility: String,
        benefits: String,
        department: String,
        officialLink: String
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.description = description
        self.eligibility = eligibility
        self.benefits = benefits
        self.department = department
        self.officialLink = officialLink
    }
}

public struct YojnaData {
    public static let defaultSchemes: [YojnaScheme] = [
        YojnaScheme(
            id: "y1",
            title: "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
            category: "Direct Income Support",
            description: "Direct income support of ₹6,000 per year in three equal four-monthly installments directly deposited into Aadhaar-linked bank accounts.",
            eligibility: "All landholding farmer families with cultivable landholding in their names across India.",
            benefits: "₹6,000 per annum paid in 3 installments of ₹2,000 each via DBT.",
            department: "Ministry of Agriculture & Farmers Welfare",
            officialLink: "https://pmkisan.gov.in"
        ),
        YojnaScheme(
            id: "y2",
            title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
            category: "Crop Insurance",
            description: "Comprehensive financial support to farmers suffering crop loss/damage arising out of non-preventable natural risks.",
            eligibility: "All farmers growing notified crops in notified areas including sharecroppers and tenant farmers.",
            benefits: "Maximum premium of 2.0% for Kharif, 1.5% for Rabi food/oilseed crops, and 5% for commercial/horticultural crops; full sum insured coverage.",
            department: "Department of Agriculture & Farmers Welfare",
            officialLink: "https://pmfby.gov.in"
        ),
        YojnaScheme(
            id: "y3",
            title: "Kisan Credit Card (KCC) Scheme",
            category: "Credit & Concessional Loans",
            description: "Provides adequate and timely credit support from the banking system to farmers for investment credit & cultivation needs.",
            eligibility: "Farmers - individual/joint borrowers, tenant farmers, oral lessees & Self Help Groups (SHGs).",
            benefits: "Crop loans up to ₹3 Lakh at an effective concessional interest rate of 4% per annum upon prompt repayment.",
            department: "NABARD & Reserve Bank of India",
            officialLink: "https://myaadhaar.uidai.gov.in"
        ),
        YojnaScheme(
            id: "y4",
            title: "Soil Health Card Scheme",
            category: "Soil Diagnostics",
            description: "Issued to farmers with crop-wise recommendations of nutrients and fertilizers required for their individual farm holdings.",
            eligibility: "All farmers with operational agricultural land across India.",
            benefits: "Free 12-parameter soil testing report (N, P, K, S, Zn, Fe, Cu, Mn, Bo, pH, EC, OC) every 3 years with customized fertilizer dosing advisory.",
            department: "National Mission for Sustainable Agriculture",
            officialLink: "https://soilhealth.dac.gov.in"
        )
    ]
}
