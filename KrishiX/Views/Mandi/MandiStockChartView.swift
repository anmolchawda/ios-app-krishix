import SwiftUI

public struct MandiStockChartView: View {
    public let candles: [DailyMandiCandle]
    public let mspPrice: Double
    
    @ObservedObject private var firebase = FirebaseManager.shared
    
    public init(candles: [DailyMandiCandle], mspPrice: Double = 2275.0) {
        self.candles = candles
        self.mspPrice = mspPrice
    }
    
    private var minOverall: Double {
        let lowest = candles.map { $0.minPrice }.min() ?? 2000.0
        return min(lowest, mspPrice) - 50
    }
    
    private var maxOverall: Double {
        let highest = candles.map { $0.maxPrice }.max() ?? 2600.0
        return highest + 50
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("7-Day Mandi Price & Arrival Trend")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                    Text("Daily Modal & Min-Max Range (₹/Quintal)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle().fill(Color(red: 0.13, green: 0.55, blue: 0.28)).frame(width: 8, height: 8)
                        Text("Modal").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                    }
                    HStack(spacing: 4) {
                        Rectangle().stroke(Color.orange, style: StrokeStyle(lineWidth: 1, dash: [3])).frame(width: 12, height: 1)
                        Text("MSP").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                    }
                }
            }
            
            // Interactive Chart Canvas
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height - 24
                let stepX = w / CGFloat(max(candles.count, 1))
                let range = maxOverall - minOverall
                
                ZStack(alignment: .topLeading) {
                    // Background horizontal grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            Divider().background(Color.gray.opacity(0.15))
                            Spacer()
                        }
                    }
                    .frame(height: h)
                    
                    // MSP Reference Line
                    let mspY = h - CGFloat((mspPrice - minOverall) / range) * h
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: mspY))
                        path.addLine(to: CGPoint(x: w, y: mspY))
                    }
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    // Candlestick & Modal Bars
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(candles.indices, id: \.self) { i in
                            let candle = candles[i]
                            let minH = CGFloat((candle.minPrice - minOverall) / range) * h
                            let maxH = CGFloat((candle.maxPrice - minOverall) / range) * h
                            let modalH = CGFloat((candle.modalPrice - minOverall) / range) * h
                            
                            VStack(spacing: 4) {
                                ZStack(alignment: .bottom) {
                                    // High-Low thin wick
                                    Rectangle()
                                        .fill(candle.isBullish ? Color(red: 0.13, green: 0.55, blue: 0.28) : Color.red)
                                        .frame(width: 2, height: max(maxH - minH, 4))
                                        .offset(y: -(minH))
                                    
                                    // Modal price marker pill
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(candle.isBullish ? Color(red: 0.13, green: 0.55, blue: 0.28) : Color.red)
                                        .frame(width: 18, height: 12)
                                        .overlay(
                                            Text("₹\(Int(candle.modalPrice))")
                                                .font(.system(size: 7, weight: .black))
                                                .foregroundColor(.white)
                                        )
                                        .offset(y: -(modalH - 6))
                                }
                                .frame(height: h, alignment: .bottom)
                                
                                // Day of week label
                                Text(candle.dayOfWeek)
                                    .font(.system(size: 10, weight: candle.isReportedToday ? .bold : .regular))
                                    .foregroundColor(candle.isReportedToday ? Color(red: 0.13, green: 0.55, blue: 0.28) : .gray)
                            }
                            .frame(width: stepX)
                        }
                    }
                }
            }
            .frame(height: 180)
            
            // Arrivals volume summary
            HStack {
                Text("Today's Arrivals: 1,420 Tonnes")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.3, green: 0.3, blue: 0.3))
                Spacer()
                Text("Govt. MSP Benchmark: ₹\(Int(mspPrice))/Qtl")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
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
}
