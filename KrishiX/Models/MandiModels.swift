import Foundation

public struct DailyMandiCandle: Identifiable, Codable, Equatable {
    public var id: String { dateLabel }
    public var dateLabel: String
    public var dayOfWeek: String
    public var minPrice: Double
    public var maxPrice: Double
    public var modalPrice: Double
    public var previousModalPrice: Double
    public var arrivalTonnes: Int
    public var isBullish: Bool
    public var isReportedToday: Bool

    public init(
        dateLabel: String,
        dayOfWeek: String,
        minPrice: Double,
        maxPrice: Double,
        modalPrice: Double,
        previousModalPrice: Double,
        arrivalTonnes: Int,
        isBullish: Bool,
        isReportedToday: Bool = false
    ) {
        self.dateLabel = dateLabel
        self.dayOfWeek = dayOfWeek
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.modalPrice = modalPrice
        self.previousModalPrice = previousModalPrice
        self.arrivalTonnes = arrivalTonnes
        self.isBullish = isBullish
        self.isReportedToday = isReportedToday
    }
}

public struct MandiPriceRecord: Identifiable, Codable, Equatable {
    public var id: String { "\(market)_\(commodity)" }
    public var state: String
    public var district: String
    public var market: String
    public var commodity: String
    public var variety: String
    public var grade: String
    public var arrivalDate: String
    public var minPrice: Double
    public var maxPrice: Double
    public var modalPrice: Double
    public var arrivalTonnes: Int

    public init(
        state: String = "",
        district: String = "",
        market: String = "",
        commodity: String = "",
        variety: String = "FAQ",
        grade: String = "FAQ",
        arrivalDate: String = "Today (Live)",
        minPrice: Double = 0.0,
        maxPrice: Double = 0.0,
        modalPrice: Double = 0.0,
        arrivalTonnes: Int = 0
    ) {
        self.state = state
        self.district = district
        self.market = market
        self.commodity = commodity
        self.variety = variety
        self.grade = grade
        self.arrivalDate = arrivalDate
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.modalPrice = modalPrice
        self.arrivalTonnes = arrivalTonnes
    }
}

public struct MandiGeoData {
    public static let states = [
        "Madhya Pradesh", "Maharashtra", "Rajasthan", "Gujarat",
        "Punjab", "Haryana", "Uttar Pradesh", "Chhattisgarh",
        "Karnataka", "Telangana", "Andhra Pradesh", "Tamil Nadu"
    ]

    public static let stateHierarchy: [String: [String]] = [
        "Madhya Pradesh": ["Indore", "Dewas", "Ujjain", "Dhar", "Bhopal", "Gwalior"],
        "Maharashtra": ["Mumbai", "Pune", "Nashik", "Nagpur", "Aurangabad", "Solapur"],
        "Gujarat": ["Ahmedabad", "Rajkot", "Surat", "Vadodara", "Bhavnagar"],
        "Punjab": ["Ludhiana", "Amritsar", "Jalandhar", "Patiala", "Bathinda"],
        "Haryana": ["Karnal", "Hisar", "Ambala", "Rohtak", "Sirsa"],
        "Rajasthan": ["Jaipur", "Kota", "Jodhpur", "Bikaner", "Sri Ganganagar"],
        "Chhattisgarh": ["Raipur", "Durg", "Bilaspur", "Rajnandgaon"]
    ]

    public static let commodities = [
        "Wheat", "Paddy (Dhan)", "Mustard", "Soybean", "Cotton",
        "Maize", "Gram (Chana)", "Onion", "Potato", "Tomato",
        "Chilli (Dry)", "Garlic", "Ginger", "Turmeric"
    ]

    public static func generate7DayCandles(baseModalPrice: Double) -> [DailyMandiCandle] {
        let days = ["16 Nov", "17 Nov", "18 Nov", "19 Nov", "20 Nov", "21 Nov", "Today"]
        let dows = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let multipliers = [0.97, 0.985, 0.98, 1.01, 1.025, 1.018, 1.03]
        let volumes = [85, 120, 110, 165, 190, 140, 210]

        var candles: [DailyMandiCandle] = []
        var prev = baseModalPrice * 0.96

        for i in 0..<days.count {
            let modal = baseModalPrice * multipliers[i]
            let isBull = modal >= prev
            let spread = modal * 0.035
            let minP = modal - spread
            let maxP = modal + spread
            let c = DailyMandiCandle(
                dateLabel: days[i],
                dayOfWeek: dows[i],
                minPrice: minP,
                maxPrice: maxP,
                modalPrice: modal,
                previousModalPrice: prev,
                arrivalTonnes: volumes[i],
                isBullish: isBull,
                isReportedToday: i == days.count - 1
            )
            candles.append(c)
            prev = modal
        }
        return candles
    }
}
