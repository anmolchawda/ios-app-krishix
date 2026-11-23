import SwiftUI

public struct MandiView: View {
    public var onOpenDrawer: () -> Void
    
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
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    var districtOptions: [String] {
        MandiGeoData.stateHierarchy[selectedState] ?? ["Main Yard"]
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            KrishiTopBar(onOpenDrawer: onOpenDrawer)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header & Filter Card
                    filterCard
                    
                    // Current Price Overview
                    priceOverviewCard
                    
                    // 7-Day Candlestick & Trend Chart
                    MandiStockChartView(candles: weeklyCandles, mspPrice: 2275.0)
                    
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
    
    // MARK: - Mandi Advisory Card
    private var mandiAdvisoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .font(.system(size: 16))
                Text("APMC Yard Operational & Dispatch Guidance")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "storefront.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 13))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gate Auction Hours: 06:00 AM – 12:30 PM")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                        Text("Electronic weighbridge & sample inspection active. Arrive early for top lot priority.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 13))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quality & Grading Precaution")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : .primary)
                        Text("Maintain moisture below 12% and remove chaff to qualify for Grade-A bidding premium.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        .font(.system(size: 13))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Price Trend vs MSP: ₹175/Qtl Premium")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        Text("Current market arrivals are clearing at favorable rates. Bullish momentum expected through mid-week.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
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

    // MARK: - Price Overview Card
    private var priceOverviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(currentRecord.commodity) (\(currentRecord.variety))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    
                    Text("\(currentRecord.market), \(currentRecord.state)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(Int(currentRecord.modalPrice))")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                    
                    Text("per Quintal")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 12) {
                priceStat(title: "Min Price", price: "₹\(Int(currentRecord.minPrice))", color: .gray)
                priceStat(title: "Modal Price", price: "₹\(Int(currentRecord.modalPrice))", color: Color(red: 0.13, green: 0.55, blue: 0.28))
                priceStat(title: "Max Price", price: "₹\(Int(currentRecord.maxPrice))", color: Color(red: 0.13, green: 0.55, blue: 0.28))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
    
    private func priceStat(title: String, price: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
            Text(price)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(firebase.isDarkTheme ? Color(red: 0.16, green: 0.17, blue: 0.20) : Color(red: 0.96, green: 0.97, blue: 0.98))
        .cornerRadius(8)
    }
    
    private func searchPrices() {
        let base: Double
        switch selectedCommodity {
        case "Wheat": base = 2450.0
        case "Soybean": base = 4800.0
        case "Cotton": base = 6900.0
        case "Paddy (Dhan)": base = 2183.0
        case "Mustard": base = 5400.0
        case "Onion": base = 1800.0
        case "Tomato": base = 2200.0
        default: base = 2500.0
        }
        
        currentRecord = MandiPriceRecord(
            state: selectedState,
            district: selectedDistrict,
            market: selectedMarket,
            commodity: selectedCommodity,
            variety: "Standard FAQ",
            grade: "FAQ Grade A",
            arrivalDate: "Today (Live)",
            minPrice: base * 0.92,
            maxPrice: base * 1.08,
            modalPrice: base,
            arrivalTonnes: Int.random(in: 450...1800)
        )
        
        weeklyCandles = MandiPriceEngine.generate7DayCandles(commodity: selectedCommodity, baseModal: base)
    }
}
