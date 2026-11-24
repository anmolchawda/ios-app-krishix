import SwiftUI

public struct RadarView: View {
    public var onOpenDrawer: () -> Void
    public var onConsultDoctor: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedRadiusKm: Int = 30
    
    let radiusOptions = [15, 30, 50, 100]
    
    let diseaseAlerts = [
        RegionalDiseaseAlert(
            district: "Indore",
            state: "Madhya Pradesh",
            cropName: "Wheat",
            diseaseName: "Yellow Rust (Puccinia striiformis)",
            severity: "High",
            reportedFarmsCount: 18,
            recommendedAction: "Prophylactic spray of Propiconazole 25% EC (1ml/L) recommended within 48h.",
            timeAgo: "3 hours ago"
        ),
        RegionalDiseaseAlert(
            district: "Durg",
            state: "Chhattisgarh",
            cropName: "Brinjal",
            diseaseName: "Shoot & Fruit Borer (Leucinodes orbonalis)",
            severity: "Moderate",
            reportedFarmsCount: 9,
            recommendedAction: "Install pheromone traps @ 12/acre and spray Emamectin Benzoate 5% SG.",
            timeAgo: "6 hours ago"
        ),
        RegionalDiseaseAlert(
            district: "Nashik",
            state: "Maharashtra",
            cropName: "Tomato",
            diseaseName: "Early Blight (Alternaria solani)",
            severity: "Moderate",
            reportedFarmsCount: 14,
            recommendedAction: "Foliar spray with Mancozeb 75% WP @ 2g/L of water.",
            timeAgo: "Yesterday"
        )
    ]
    
    public init(
        onOpenDrawer: @escaping () -> Void,
        onConsultDoctor: @escaping () -> Void,
        onBack: (() -> Void)? = nil
    ) {
        self.onOpenDrawer = onOpenDrawer
        self.onConsultDoctor = onConsultDoctor
        self.onBack = onBack
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(
                onOpenDrawer: onOpenDrawer,
                showBackButton: true,
                onBack: onBack
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // Radius Selector
                    radiusSelectorBar
                    
                    // Radar Visual Graphic Card
                    radarVisualCard
                    
                    // Outbreak Alerts Feed
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Outbreak Alerts (\(diseaseAlerts.count))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                            Spacer()
                        }
                        
                        ForEach(diseaseAlerts) { alert in
                            outbreakAlertCard(alert: alert)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    // MARK: - Radius Selector Bar
    private var radiusSelectorBar: some View {
        HStack {
            Text("Surveillance Radius:")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
            
            Spacer()
            
            HStack(spacing: 6) {
                ForEach(radiusOptions, id: \.self) { r in
                    Button(action: { selectedRadiusKm = r }) {
                        Text("\(r) km")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedRadiusKm == r ? .white : Color(red: 0.13, green: 0.55, blue: 0.28))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selectedRadiusKm == r ?
                                Color(red: 0.13, green: 0.55, blue: 0.28) :
                                Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.12)
                            )
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
        )
    }
    
    // MARK: - Radar Visual Graphic Card
    private var radarVisualCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [Color(red: 0.05, green: 0.15, blue: 0.08), Color(red: 0.02, green: 0.08, blue: 0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // Concentric Radar Rings
            ZStack {
                Circle().stroke(Color.green.opacity(0.15), lineWidth: 1).frame(width: 220, height: 220)
                Circle().stroke(Color.green.opacity(0.25), lineWidth: 1).frame(width: 150, height: 150)
                Circle().stroke(Color.green.opacity(0.35), lineWidth: 1).frame(width: 80, height: 80)
                
                // Radar Crosshairs
                Rectangle().fill(Color.green.opacity(0.2)).frame(width: 220, height: 1)
                Rectangle().fill(Color.green.opacity(0.2)).frame(width: 1, height: 220)
                
                // Farmer's own center location
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: .white, radius: 4)
                
                // Disease outbreak blips
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .offset(x: 45, y: -35)
                    .shadow(color: .red, radius: 5)
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 10, height: 10)
                    .offset(x: -50, y: 30)
                    .shadow(color: .orange, radius: 4)
            }
            .padding(.vertical, 30)
            
            // Radar overlay HUD labels
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("RADAR LIVE SURVEILLANCE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Text("\(selectedRadiusKm) KM SCAN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green.opacity(0.8))
                }
                Spacer()
                HStack {
                    Text("GPS Locked: Central India Zone")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("3 Active Threats")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .padding(16)
        }
        .frame(height: 240)
    }
    
    // MARK: - Outbreak Alert Card
    private func outbreakAlertCard(alert: RegionalDiseaseAlert) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.diseaseName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    
                    Text("\(alert.cropName) • \(alert.district), \(alert.state)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(alert.severity.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(alert.severity == "High" ? .red : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((alert.severity == "High" ? Color.red : Color.orange).opacity(0.12))
                    .cornerRadius(6)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(Color.orange)
                    .font(.system(size: 12))
                Text("\(alert.reportedFarmsCount) nearby farms confirmed symptoms")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.orange)
            }
            
            Text("Advisory: \(alert.recommendedAction)")
                .font(.system(size: 12))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
                .lineSpacing(2)
            
            HStack {
                Text(alert.timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: onConsultDoctor) {
                    HStack(spacing: 4) {
                        Image(systemName: "stethoscope")
                        Text("Consult AI Doctor")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .cornerRadius(8)
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
