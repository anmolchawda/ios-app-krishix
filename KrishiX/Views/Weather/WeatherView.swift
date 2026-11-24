import SwiftUI
import UIKit

public struct WeatherView: View {
    public var onOpenDrawer: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var searchText: String = ""
    @State private var suggestions: [String] = []
    @State private var weatherInfo = WeatherInfo()
    @State private var pushAlertsEnabled: Bool = true
    @State private var selectedDayIndex: Int = 0
    
    // 7-day Dual Temperature Data (Max & Min) matching Video rest_48.0s.jpg
    let weeklyForecastData: [(day: String, date: String, maxTemp: Int, minTemp: Int, condition: String, icon: String)] = [
        ("Tod", "24", 32, 19, "Sunny & Warm", "sun.max.fill"),
        ("Tue", "25", 33, 20, "Clear Sky", "sun.max.fill"),
        ("Wed", "26", 31, 19, "Partly Cloudy", "cloud.sun.fill"),
        ("Thu", "27", 30, 18, "Mild Wind", "wind"),
        ("Fri", "28", 29, 17, "Light Shower Risk", "cloud.drizzle.fill"),
        ("Sat", "29", 31, 18, "Clear Sky", "sun.max.fill"),
        ("Sun", "30", 32, 19, "Sunny", "sun.max.fill")
    ]
    
    let hourlyList = [
        HourlyForecast(time: "06:00", temp: 20, iconName: "sunrise.fill"),
        HourlyForecast(time: "09:00", temp: 24, iconName: "sun.max.fill"),
        HourlyForecast(time: "12:00", temp: 30, iconName: "sun.max.fill"),
        HourlyForecast(time: "15:00", temp: 32, iconName: "sun.max.fill"),
        HourlyForecast(time: "18:00", temp: 27, iconName: "cloud.sun.fill"),
        HourlyForecast(time: "21:00", temp: 23, iconName: "moon.stars.fill")
    ]
    
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
                    // Search Bar with Live Suggestions Dropdown (Requirement 11)
                    searchSection
                    
                    // Main Weather Current Overview Card
                    mainWeatherCard
                    
                    // Interactive 7-Day Dual Temperature Graph (Matching Video rest_48.0s.jpg)
                    sevenDayDualTemperatureGraph
                    
                    // Extreme Weather Push Alerts Card
                    extremeWeatherAlertsCard
                    
                    // Spraying Advisory Card
                    sprayingAdvisoryCard
                    
                    // Hourly Forecast Strip
                    hourlyForecastSection
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    // MARK: - Search Bar & Live Geocoding Suggestions Dropdown (Requirement 11)
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(translation.getString("searchLocation"), text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(firebase.isDarkTheme ? .white : .black)
                    .onChange(of: searchText) { query in
                        if query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 {
                            firebase.searchDistricts(query: query) { results in
                                self.suggestions = results
                            }
                        } else {
                            self.suggestions = []
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        suggestions = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(firebase.isDarkTheme ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color.white)
            .cornerRadius(suggestions.isEmpty ? 12 : 0)
            
            // Live Autocomplete Suggestions List
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    ForEach(suggestions, id: \.self) { place in
                        Button(action: {
                            weatherInfo.location = place
                            searchText = ""
                            suggestions = []
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
    
    // MARK: - Main Weather Card
    private var mainWeatherCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            .font(.system(size: 14))
                        Text(weatherInfo.location)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    }
                    
                    Text("Today, \(weeklyForecastData[selectedDayIndex].condition)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: weeklyForecastData[selectedDayIndex].icon)
                    .font(.system(size: 38))
                    .foregroundColor(.orange)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("\(weeklyForecastData[selectedDayIndex].maxTemp)°C")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Text("/ \(weeklyForecastData[selectedDayIndex].minTemp)°C")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // Atmospheric Parameters Grid
            HStack(spacing: 16) {
                weatherStat(icon: "humidity.fill", title: "Humidity", value: "\(weatherInfo.humidity)%")
                weatherStat(icon: "wind", title: "Wind", value: "\(weatherInfo.windSpeed) km/h")
                weatherStat(icon: "drop.fill", title: "Precipitation", value: "\(weatherInfo.precipitation)%")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func weatherStat(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 7-Day Dual Temperature Graph (Matching Video rest_48.0s.jpg)
    private var sevenDayDualTemperatureGraph: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("7-Day Temperature Trend")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.orange).frame(width: 8, height: 8)
                        Text("Max").font(.system(size: 11, weight: .bold)).foregroundColor(.orange)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.blue).frame(width: 8, height: 8)
                        Text("Min").font(.system(size: 11, weight: .bold)).foregroundColor(.blue)
                    }
                }
            }
            
            // Day Selector Pills Row (Tod 24, Tue 25, Wed 26, ...)
            HStack(spacing: 6) {
                ForEach(0..<weeklyForecastData.count, id: \.self) { idx in
                    let item = weeklyForecastData[idx]
                    Button(action: {
                        selectedDayIndex = idx
                    }) {
                        VStack(spacing: 2) {
                            Text(item.day)
                                .font(.system(size: 11, weight: selectedDayIndex == idx ? .heavy : .semibold))
                            Text(item.date)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(selectedDayIndex == idx ? .white : (firebase.isDarkTheme ? .white.opacity(0.8) : Color.primary))
                        .background(
                            selectedDayIndex == idx ?
                            Color(red: 0.13, green: 0.55, blue: 0.28) :
                            (firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.94, green: 0.95, blue: 0.96))
                        )
                        .cornerRadius(10)
                    }
                }
            }
            
            // Dual Temperature Curve Canvas
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                let stepX = width / CGFloat(max(1, weeklyForecastData.count - 1))
                
                // Max temps (Orange line)
                let maxPoints: [CGPoint] = weeklyForecastData.enumerated().map { idx, item in
                    let norm = CGFloat(item.maxTemp - 15) / 25.0
                    let y = height * (1.0 - norm * 0.7 - 0.25)
                    return CGPoint(x: CGFloat(idx) * stepX, y: y)
                }
                
                // Min temps (Blue line)
                let minPoints: [CGPoint] = weeklyForecastData.enumerated().map { idx, item in
                    let norm = CGFloat(item.minTemp - 10) / 25.0
                    let y = height * (1.0 - norm * 0.7 - 0.05)
                    return CGPoint(x: CGFloat(idx) * stepX, y: y)
                }
                
                ZStack {
                    // Orange Max Line
                    Path { path in
                        for (i, pt) in maxPoints.enumerated() {
                            if i == 0 { path.move(to: pt) }
                            else { path.addLine(to: pt) }
                        }
                    }
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    
                    // Blue Min Line
                    Path { path in
                        for (i, pt) in minPoints.enumerated() {
                            if i == 0 { path.move(to: pt) }
                            else { path.addLine(to: pt) }
                        }
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    
                    // Dots & Numbers
                    ForEach(0..<maxPoints.count, id: \.self) { i in
                        Circle().fill(Color.orange).frame(width: 6, height: 6).position(maxPoints[i])
                        Text("\(weeklyForecastData[i].maxTemp)°")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                            .position(x: maxPoints[i].x, y: maxPoints[i].y - 12)
                        
                        Circle().fill(Color.blue).frame(width: 6, height: 6).position(minPoints[i])
                        Text("\(weeklyForecastData[i].minTemp)°")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                            .position(x: minPoints[i].x, y: minPoints[i].y + 12)
                    }
                }
            }
            .frame(height: 110)
            .padding(.top, 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Extreme Weather Push Alerts Card
    private var extremeWeatherAlertsCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Extreme Weather Crop Push Alerts")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                Text("Receive instant notifications for sudden hail, frost, or unseasonal heavy rain.")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $pushAlertsEnabled)
                .labelsHidden()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
        )
    }
    
    // MARK: - Spraying Advisory Card
    private var sprayingAdvisoryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "drop.triangle.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                Text("Agronomic Spraying Window Advisory")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("OPTIMAL WINDOW")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    Text("06:00 AM - 09:30 AM")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("SPRAY FEASIBILITY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.blue)
                    Text("High (Wind < 10 km/h)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.25), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Hourly Forecast Section
    private var hourlyForecastSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hourly Temperature Progression")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hourlyList, id: \.time) { item in
                        VStack(spacing: 6) {
                            Text(item.time)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Image(systemName: item.iconName)
                                .font(.system(size: 18))
                                .foregroundColor(.orange)
                            
                            Text("\(item.temp)°C")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(firebase.isDarkTheme ? Color(red: 0.15, green: 0.16, blue: 0.19) : Color.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}
