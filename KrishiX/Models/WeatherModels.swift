import Foundation

public struct WeatherInfo: Equatable {
    public var location: String
    public var temp: Int
    public var condition: String
    public var humidity: Int
    public var windSpeedKm: Int
    public var rainChance: Int
    public var sprayAdvisory: String
    public var isSpraySafe: Bool

    public init(
        location: String = "Mumbai, Maharashtra",
        temp: Int = 22,
        condition: String = "Clear Sky & Sunny",
        humidity: Int = 52,
        windSpeedKm: Int = 5,
        rainChance: Int = 0,
        sprayAdvisory: String = "Ideal conditions for foliar & chemical spraying during early morning hours.",
        isSpraySafe: Bool = true
    ) {
        self.location = location
        self.temp = temp
        self.condition = condition
        self.humidity = humidity
        self.windSpeedKm = windSpeedKm
        self.rainChance = rainChance
        self.sprayAdvisory = sprayAdvisory
        self.isSpraySafe = isSpraySafe
    }
}

public struct HourlyForecast: Identifiable, Equatable {
    public var id: String { time }
    public var time: String
    public var temp: Int
    public var iconName: String

    public init(time: String, temp: Int, iconName: String = "sun.max.fill") {
        self.time = time
        self.temp = temp
        self.iconName = iconName
    }
}

public struct DailyForecast: Identifiable, Equatable {
    public var id: String { day }
    public var day: String
    public var date: String
    public var condition: String
    public var maxTemp: Int
    public var minTemp: Int
    public var rainChance: Int
    public var iconType: String
    public var sprayAdvisory: String

    public init(
        day: String,
        date: String = "",
        condition: String,
        maxTemp: Int,
        minTemp: Int,
        rainChance: Int,
        iconType: String = "sun.max.fill",
        sprayAdvisory: String = "Safe for chemical & foliar spraying in early morning."
    ) {
        self.day = day
        self.date = date
        self.condition = condition
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.rainChance = rainChance
        self.iconType = iconType
        self.sprayAdvisory = sprayAdvisory
    }
}

public struct RegionalDiseaseAlert: Identifiable, Codable, Equatable {
    public var id: String
    public var district: String
    public var state: String
    public var cropName: String
    public var diseaseName: String
    public var severity: String
    public var reportedFarmsCount: Int
    public var recommendedAction: String
    public var timeAgo: String

    public init(
        id: String = UUID().uuidString,
        district: String = "Indore",
        state: String = "Madhya Pradesh",
        cropName: String = "Wheat",
        diseaseName: String = "Yellow Rust (Puccinia striiformis)",
        severity: String = "High",
        reportedFarmsCount: Int = 18,
        recommendedAction: String = "Prophylactic spray of Propiconazole 25% EC (1ml/L) recommended within 48h.",
        timeAgo: String = "3 hours ago"
    ) {
        self.id = id
        self.district = district
        self.state = state
        self.cropName = cropName
        self.diseaseName = diseaseName
        self.severity = severity
        self.reportedFarmsCount = reportedFarmsCount
        self.recommendedAction = recommendedAction
        self.timeAgo = timeAgo
    }
}
