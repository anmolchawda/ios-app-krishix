import SwiftUI

public struct WeatherView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var weatherInfo = WeatherInfo()
    
    let allDistricts = [
        "Mumbai, Maharashtra", "Pune, Maharashtra", "Nashik, Maharashtra", "Nagpur, Maharashtra",
        "Indore, Madhya Pradesh", "Bhopal, Madhya Pradesh", "Ujjain, Madhya Pradesh", "Dewas, Madhya Pradesh",
        "Raipur, Chhattisgarh", "Durg, Chhattisgarh", "Bilaspur, Chhattisgarh",
        "Jaipur, Rajasthan", "Kota, Rajasthan", "Jodhpur, Rajasthan",
        "Ahmedabad, Gujarat", "Surat, Gujarat", "Rajkot, Gujarat",
        "Ludhiana, Punjab", "Amritsar, Punjab", "Karnal, Haryana"
    ]
    
    let hourlyList = [
        HourlyForecast(time: "06:00", temp: 20, iconName: "sunrise.fill"),
        HourlyForecast(time: "09:00", temp: 23, iconName: "sun.max.fill"),
        HourlyForecast(time: "12:00", temp: 27, iconName: "sun.max.fill"),
        HourlyForecast(time: "15:00", temp: 28, iconName: "sun.max.fill"),
        HourlyForecast(time: "18:00", temp: 24, iconName: "cloud.sun.fill"),
        HourlyForecast(time: "21:00", temp: 22, iconName: "moon.stars.fill")
    ]
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    var suggestions: [String] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }
        return allDistricts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar with Live Suggestions Dropdown
                    searchSection
                    
                    // Location Disabled Alert Banner
                    locationBanner
                    
                    // Main Weather Card
                    mainWeatherCard
                    
                    // Hourly Forecast Strip
                    hourlyForecastSection
                    
                    // Seasonal Pass Card
                    seasonalPassCard
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    // MARK: - Search Bar & Live Dropdown
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(translation.getString("searchLocation"), text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(firebase.isDarkTheme ? .white : .black)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .cornerRadius(suggestions.isEmpty ? 12 : 0)
            
            // Autocomplete suggestions list
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    ForEach(suggestions, id: \.self) { place in
                        Button(action: {
                            weatherInfo.location = place
                            searchText = ""
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .font(.system(size: 14))
                                Text(place)
                                    .font(.system(size: 14))
                                    .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                        Divider()
                    }
                }
                .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color.white)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    // MARK: - Location Banner
    private var locationBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "location.slash.fill")
                .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.15))
                .font(.system(size: 14))
            
            Text("Location disabled • Tap to enable GPS for hyper-local advisory")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(firebase.isDarkTheme ? Color(red: 0.15, green: 0.16, blue: 0.19) : Color.white)
        )
    }
    
    // MARK: - Main Weather Card
    private var mainWeatherCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .font(.system(size: 14))
                        Text(weatherInfo.location)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    }
                    
                    Text(weatherInfo.condition)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(weatherInfo.temp)°C")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
            
            // Spray Advisory Banner
            HStack(spacing: 8) {
                Image(systemName: weatherInfo.isSpraySafe ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(weatherInfo.isSpraySafe ? Color(red: 0.13, green: 0.55, blue: 0.28) : .orange)
                
                Text(weatherInfo.sprayAdvisory)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.9) : Color(red: 0.15, green: 0.18, blue: 0.22))
            }
            .padding(12)
            .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.10))
            .cornerRadius(10)
            
            // 3-Metric Grid: Humidity, Wind, Rain
            HStack(spacing: 12) {
                metricBox(title: "Humidity", value: "\(weatherInfo.humidity)%", icon: "humidity")
                metricBox(title: "Wind Speed", value: "\(weatherInfo.windSpeedKm) km/h", icon: "wind")
                metricBox(title: "Rainfall", value: "\(weatherInfo.rainChance)%", icon: "cloud.rain.fill")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func metricBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : .primary)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.96, green: 0.97, blue: 0.98))
        .cornerRadius(10)
    }
    
    // MARK: - Hourly Forecast
    private var hourlyForecastSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("6-Hour Forecast")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.22, blue: 0.25))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hourlyList) { hour in
                        VStack(spacing: 6) {
                            Text(hour.time)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Image(systemName: hour.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.90, green: 0.65, blue: 0.15))
                            
                            Text("\(hour.temp)°C")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Seasonal Pass Card
    private var seasonalPassCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    Text("₹249 Seasonal Pass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                }
                Text("Unlimited weather alerts, spray windows & frost warnings")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Active")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
        )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
