import SwiftUI

public struct MandiView: View {
    public var onOpenDrawer: () -> Void
    public var onBack: (() -> Void)? = nil
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedState: String = "Madhya Pradesh"
    @State private var selectedDistrict: String = "Indore"
    @State private var selectedMarket: String = "Indore Mandi Yard"
    @State private var selectedCommodity: String = "Wheat"
    
    @State private var currentRecord = MandiPriceRecord(
        state: "Madhya Pradesh",
        district: "Indore",
        market: "Indore Mandi Yard",
        commodity: "Wheat",
        variety: "Sharbati FAQ",
        grade: "Grade A",
        arrivalDate: "Today (Live)",
        minPrice: 2280.0,
        maxPrice: 2620.0,
        modalPrice: 2450.0,
        arrivalTonnes: 1420
    )
    
    @State private var weeklyCandles = MandiPriceEngine.generate7DayCandles(commodity: "Wheat", baseModal: 2450.0)
    @State private var mspBenchmark: Double = 2275.0
    
    public init(onOpenDrawer: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.onOpenDrawer = onOpenDrawer
        self.onBack = onBack
    }
    
    var districtOptions: [String] {
        MandiGeoData.stateHierarchy[selectedState] ?? ["Main Yard"]
    }
    
    var mspDifference: Double {
        currentRecord.modalPrice - mspBenchmark
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
                    // Header & Filter Card
                    filterCard
                    
                    // Current Price Overview (Matching Video rest_50.0s.jpg)
                    priceOverviewCard
                    
                    // 7-Day Candlestick & MSP Chart (Requirement 12)
                    MandiStockChartView(candles: weeklyCandles, mspPrice: mspBenchmark)
                    
                    // APMC Mandi Operational & Dispatch Advisory Card
                    mandiAdvisoryCard
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.97))
        }
    }
    
    // MARK: - Filter Card
    private var filterCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(translation.getString("apmcBadge"))
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .cornerRadius(6)
                
                Text(translation.getString("mandiTitle"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            VStack(spacing: 10) {
                dropdownPicker(label: "State", selection: $selectedState, options: MandiGeoData.states) { newState in
                    if let firstDist = MandiGeoData.stateHierarchy[newState]?.first {
                        selectedDistrict = firstDist
                        selectedMarket = "\(firstDist) Mandi Yard"
                    }
                }
                
                dropdownPicker(label: "District", selection: $selectedDistrict, options: districtOptions) { newDist in
                    selectedMarket = "\(newDist) Mandi Yard"
                }
                
                dropdownPicker(label: "Market Yard", selection: $selectedMarket, options: [
                    "\(selectedDistrict) Mandi Yard",
                    "\(selectedDistrict) Sub-Yard A",
                    "\(selectedDistrict) Farmers Market"
                ])
                
                dropdownPicker(label: "Commodity", selection: $selectedCommodity, options: MandiGeoData.commodities)
            }
            
            Button(action: searchPrices) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search Mandi Prices")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundColor(.white)
                .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                .cornerRadius(12)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func dropdownPicker(label: String, selection: Binding<String>, options: [String], onChange: ((String) -> Void)? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
                .frame(width: 90, alignment: .leading)
            
            Spacer()
            
            Menu {
                ForEach(options, id: \.self) { opt in
                    Button(opt) {
                        selection.wrappedValue = opt
                        onChange?(opt)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection.wrappedValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color(red: 0.95, green: 0.96, blue: 0.97))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Price Overview Card (Matching Video rest_50.0s.jpg: Modal Price & Below/Above MSP Badge)
    private var priceOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentRecord.commodity)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    Text("\(currentRecord.market) • \(currentRecord.variety)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Below or Above MSP Badge (Matching Video rest_50.0s.jpg)
                HStack(spacing: 4) {
                    Image(systemName: mspDifference >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(mspDifference >= 0 ? "+₹\(Int(mspDifference)) Above MSP" : "-₹\(Int(abs(mspDifference))) Below MSP")
                        .font(.system(size: 11, weight: .heavy))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(mspDifference >= 0 ? Color(red: 0.13, green: 0.55, blue: 0.28) : .red)
                .background(
                    (mspDifference >= 0 ? Color(red: 0.13, green: 0.55, blue: 0.28) : Color.red).opacity(0.12)
                )
                .cornerRadius(8)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("₹\(Int(currentRecord.modalPrice))")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                
                Text("/ Quintal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Govt. MSP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text("₹\(Int(mspBenchmark))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.orange)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Min Rate")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text("₹\(Int(currentRecord.minPrice))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Max Rate")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text("₹\(Int(currentRecord.maxPrice))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Daily Arrival")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text("\(currentRecord.arrivalTonnes) Tonnes")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Mandi Advisory Card
    private var mandiAdvisoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                Text("APMC Yard Operational Hours & Advisory")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                bullet(text: "Daily Open Auction Bidding: 09:00 AM - 02:00 PM")
                bullet(text: "Gate Entry & Weighbridge tokens issued till 11:30 AM")
                bullet(text: "Traders participation: Active (Grade-A clean produce fetched 8-12% premium)")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
        )
    }
    
    private func bullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.25, green: 0.28, blue: 0.30))
        }
    }
    
    private func searchPrices() {
        firebase.fetchLiveMandiPrices(
            state: selectedState,
            district: selectedDistrict,
            commodity: selectedCommodity
        ) { records, candles in
            if let first = records.first {
                self.currentRecord = first
            }
            self.weeklyCandles = candles
            self.mspBenchmark = MandiGeoData.mspBenchmark(for: selectedCommodity)
        }
    }
}
