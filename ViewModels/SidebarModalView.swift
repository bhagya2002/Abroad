//
//  SidebarModalView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-20.
//

import SwiftUI
import Charts

struct SidebarModalView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: PinsViewModel
    @AppStorage("userCarbonGoal") var userCarbonGoal: Double = 5000.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }

            Rectangle()
                .fill(Material.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("My Travel Insights")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 10)

                ScrollView {
                    VStack(spacing: 15) {
                        createCarbonProgressView()
                        createEcoBadgesView()
                        createRealWorldImpactView()
//                      createTravelEfficiencyScore()
                        createGlobalRankView()
                        createFlightImpactWarning()
                        createTransportModePieChart()
                        createTransportInsightsView()
//                        createMostVisitedPlacesView()
                        createLocationsSummaryView()
                    }
                    .padding()
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.75)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
            .onTapGesture { }
        }
    }

    // MARK: - Sidebar Sections

    private func createCarbonProgressView() -> some View {
        VStack(alignment: .leading) {
            Text("Your Carbon Footprint Goal")
                .font(.headline)
            ProgressView(value: getTotalEmissions(), total: getUserCarbonGoal())
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 10)
                .padding(.bottom, 5)
                .accentColor(.black)
            Text("⚠️ **\(Int(getTotalEmissions())) kg CO₂ used** / \(Int(getUserCarbonGoal())) kg CO₂ goal")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createTransportModePieChart() -> some View {
        let transportData = getTransportEmissions()
        let colors: [Color] = [.blue, .green, .red, .orange, .purple, .yellow]
        let sortedData = transportData.sorted { $0.key < $1.key }
        
        var colorMapping: [String: Color] = [:]
        for (index, element) in sortedData.enumerated() {
            colorMapping[element.key] = colors[index % colors.count]
        }
        
        return VStack(alignment: .leading) {
            Text("Your Transport Breakdown")
                .font(.headline)
                .padding(.leading, 5)
            
            if transportData.isEmpty {
                Text("No transport data available. Add a trip with transport entries to view your transport breakdown.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                HStack {
                    ZStack {
                        ForEach(Array(sortedData.enumerated()), id: \.offset) { index, element in
                            PieSliceView(
                                startAngle: angle(for: index, in: sortedData),
                                endAngle: angle(for: index + 1, in: sortedData),
                                color: colors[index % colors.count]
                            )
                        }
                    }
                    .frame(width: 250, height: 250)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total Transport Emissions: **\(Int(transportData.values.reduce(0, +))) kg CO₂**")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        ForEach(transportData.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            HStack {
                                Circle()
                                    .fill(colorMapping[key] ?? .black)
                                    .frame(width: 10, height: 10)
                                Text("\(key): \(Int(value)) kg CO₂")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.leading, 5)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func angle(for index: Int, in data: [(key: String, value: Double)]) -> Angle {
        let total = data.reduce(0) { $0 + $1.value }
        guard total != 0 else { return .degrees(0) }
        let sum = data.prefix(index).reduce(0) { $0 + $1.value }
        return .degrees((sum / total) * 360)
    }

    private func createTravelEfficiencyScore() -> some View {
        let avgScore = viewModel.averageEfficiencyScore()

        return VStack {
            Text("Travel Efficiency Score")
                .font(.headline)
                .foregroundColor(.white)

            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(avgScore) / 100)
                    .stroke(avgScore > 70 ? Color.green : Color.orange, lineWidth: 12)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 100, height: 100)

                Text("\(String(format: "%.2f", avgScore))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(height: 120)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createTransportInsightsView() -> some View {
        VStack(alignment: .leading) {
            Text("Your Best & Worst Transport Choices")
                .font(.headline)
            HStack {
                VStack {
                    Text("🌱 Best")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text(getBestTransport())
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack {
                    Text("⚠️ Worst")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Text(getWorstTransport())
                        .font(.title2)
                        .bold()
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

//    private func createCarbonTrendsView() -> some View {
//        VStack(alignment: .leading) {
//            Text("📉 Your CO₂ Savings Over Time")
//                .font(.headline)
//            ChartView(savingsData: getSavingsOverTime())
//                .frame(height: 150)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
//    }

    private func createEcoBadgesView() -> some View {
        VStack(alignment: .leading) {
            Text("🏆 Eco Badges Earned")
                .font(.headline)
            
            if viewModel.pins.isEmpty {
                Text("No trips added yet. Add a trip to start earning badges!")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else if getEcoBadges().isEmpty {
                Text("No badges earned yet. Keep traveling sustainably to unlock achievements! 🌱")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(getEcoBadges(), id: \.self) { badge in
                            VStack {
                                Image(systemName: "leaf.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.green)
                                Text(badge)
                                    .font(.caption)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.3)))
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createRealWorldImpactView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("🌱 Real-World Impact")
                .font(.headline)
            Text("**Trees Planted Equivalent:** \(getTreeEquivalent())")
            Text("**Cars Removed from Road:** \(getCarEquivalent())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createFlightImpactWarning() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Flight Impact Warning")
                .font(.headline)
                .foregroundColor(.red)
            if let highestFlight = getHighestFlightImpact() {
                Text("Your **\(highestFlight) km** flight emitted the most CO₂.")
                Text("**Taking a train could have saved 80% CO₂!**")
                    .foregroundColor(.blue)
            } else {
                Text("No recent high-emission flights detected!")
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createGlobalRankView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Your CO₂ vs. Global Travelers")
                .font(.headline)
            Text("Your emissions are **\(getGlobalRank())% better** than the average traveler!")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createMostVisitedPlacesView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("📌 Most Visited Places")
                .font(.headline)
            Text("**Country:** \(getMostVisitedCountry())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
    
    private func createLocationsSummaryView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("📍 Travel Summary")
                .font(.headline)
            Text("Locations Saved: **\(viewModel.pins.count)**")
            Text("Next Trip: **\(viewModel.pins.first(where: { $0.category == .future })?.title ?? "Plan one!")**")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    // MARK: - Helper Functions

    private func calculateCarbonSavings() -> String {
        let totalSavings = viewModel.pins.reduce(0) { $0 + ($1.tripBudget ?? 0) * 0.1 }
        return String(format: "%.2f", totalSavings)
    }

    private func getTotalEmissions() -> Double {
        return viewModel.pins.flatMap { $0.transportEntries }
            .compactMap { entry in
                let emissionFactor = CarbonEmissionFactors.emissionsPerKm[entry.mode] ?? 0
                return (Double(entry.distance) ?? 0) * emissionFactor
            }
            .reduce(0, +)
    }
    
    private func getTreeEquivalent() -> Int {
        let co2PerTree = 20.0 // 1 tree absorbs ~20kg CO₂ per year
        return max(0, Int(getTotalEmissions() / co2PerTree))
    }

    private func getCarEquivalent() -> Int {
        let co2PerCar = 2.3 // 2.3kg CO₂ per liter of gasoline burned
        return max(0, Int(getTotalEmissions() / co2PerCar))
    }

    private func getUserCarbonGoal() -> Double {
        return userCarbonGoal
    }

    private func getBestTransport() -> String {
        return getTransportEmissions().min(by: { $0.value < $1.value })?.key ?? "N/A"
    }

    private func getWorstTransport() -> String {
        return getTransportEmissions().max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private func getTravelEfficiencyScore() -> Int { return 85 }

    private func getTransportEmissions() -> [String: Double] {
        var emissions: [String: Double] = [:]
        for pin in viewModel.pins {
            for entry in pin.transportEntries {
                let emissionFactor = CarbonEmissionFactors.emissionsPerKm[entry.mode] ?? 0
                let distance = Double(entry.distance) ?? 0
                emissions[entry.mode, default: 0] += distance * emissionFactor
            }
        }
        return emissions
    }
    
    private func getHighestFlightImpact() -> String? {
        let flights = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Plane ✈️" }

        let sortedFlights = flights.sorted {
            guard let firstDistance = Double($0.distance), let secondDistance = Double($1.distance) else {
                return false
            }
            return firstDistance > secondDistance
        }

        if let highestFlight = sortedFlights.first {
            return "\(highestFlight.distance) km"
        }
        return nil
    }
    
    private func getGlobalRank() -> Int {
        let globalAverageEmissions = 4500.0 // Global traveler CO₂ per year (kg)
        let userEmissions = getTotalEmissions()

        if userEmissions == 0 { return 100 }
        
        let rank = 100 - ((userEmissions / globalAverageEmissions) * 100)
        return max(0, min(Int(rank), 100))
    }
    
    private func getMostVisitedCity() -> String {
        let cityCounts = viewModel.pins.reduce(into: [String: Int]()) { counts, pin in
            if !pin.title.isEmpty {
                counts[pin.title, default: 0] += 1
            }
        }
        return cityCounts.max(by: { $0.value < $1.value })?.key ?? "Unknown"
    }

    private func getMostVisitedCountry() -> String {
        let countryCounts = viewModel.pins.reduce(into: [String: Int]()) { counts, pin in
            if let country = pin.ecoRegion {
                counts[country, default: 0] += 1
            }
        }
        return countryCounts.max(by: { $0.value < $1.value })?.key ?? "Not yet available"
    }
    
    private func getEcoBadges() -> [String] {
        let totalEmissions = getTotalEmissions()
        var badges: [String] = []

        // Carbon Footprint Reduction Badges
        if totalEmissions < 500 { badges.append("🌱 Carbon Saver - Emitted less than 500 kg CO₂") }
        if totalEmissions < 100 { badges.append("♻️ Green Traveler - Emitted less than 100 kg CO₂") }
        if totalEmissions == 0 { badges.append("🌍 Zero Carbon Footprint - No emissions recorded!") }
        if totalEmissions > 1000 { badges.append("⚠️ High Carbon User - Over 1000 kg CO₂") }

        // Train Usage Badges
        let trainTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Train" }
        if trainTrips.count >= 5 { badges.append("🚆 Train Enthusiast - 5+ train trips") }
        if trainTrips.count >= 10 { badges.append("🌎 Rail Explorer - 10+ train trips") }
        if trainTrips.count >= 20 { badges.append("🌍 Sustainable Voyager - 20+ train trips") }

        // Walking & Biking Badges
        let walkingTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Walking" }
        let walkingDistance = walkingTrips.reduce(0) { $0 + (Double($1.distance) ?? 0) }
        
        if walkingDistance > 50 { badges.append("🚶 Walking Hero - Walked 50+ km") }
        if walkingDistance > 100 { badges.append("🥾 Trailblazer - Walked 100+ km") }
        if walkingDistance > 250 { badges.append("🏆 Urban Explorer - Walked 250+ km") }

        let bikingTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Bicycle" }
        let bikingDistance = bikingTrips.reduce(0) { $0 + (Double($1.distance) ?? 0) }
        
        if bikingDistance > 50 { badges.append("🚴‍♂️ Bike Commuter - Biked 50+ km") }
        if bikingDistance > 100 { badges.append("🚵‍♂️ Pedal Power - Biked 100+ km") }
        if bikingDistance > 200 { badges.append("🌿 Eco Cyclist - Biked 200+ km") }

        // Carpooling Badges
        let carpoolTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Carpooling" }
        if carpoolTrips.count >= 5 { badges.append("🚘 Carpool Champion - 5+ carpool trips") }
        if carpoolTrips.count >= 10 { badges.append("♻️ Shared Ride Advocate - 10+ carpool trips") }

        // Electric Vehicle Usage
        let evTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Electric Car" }
        if evTrips.count >= 3 { badges.append("🔋 EV Supporter - Used an electric car 3+ times") }
        if evTrips.count >= 10 { badges.append("⚡ Clean Energy Driver - 10+ electric car trips") }

        // Ferry Usage (Alternative to Air Travel)
        let ferryTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Ferry" }
        if ferryTrips.count >= 3 { badges.append("⛴️ Blue Water Explorer - 3+ ferry trips") }
        if ferryTrips.count >= 10 { badges.append("🌊 Ocean Traveler - 10+ ferry trips") }

        // Avoiding Flights Badges
        let flightTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Plane" }
        if flightTrips.isEmpty { badges.append("✈️ Flight-Free Traveler - No flights taken!") }
        if flightTrips.count < 3 && totalEmissions < 500 { badges.append("🌍 Conscious Flyer - Fewer than 3 flights & under 500 kg CO₂") }

        return badges
    }

    private func getSavingsOverTime() -> [Double] {
        return [50, 100, 200, 150, 300, 250] // Placeholder
    }
    
    // MARK: - Pie Chart Helper Functions
    private func angle(for index: Int, in data: [String: Double]) -> Angle {
        let total = data.values.reduce(0, +)
        let sum = data.values.prefix(index).reduce(0, +)
        return .degrees((sum / total) * 360)
    }

    struct PieSliceView: View {
        var startAngle: Angle
        var endAngle: Angle
        var color: Color

        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    let width = min(geometry.size.width, geometry.size.height)
                    let center = CGPoint(x: width / 2, y: width / 2)
                    let radius = width / 2

                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    path.closeSubpath()
                }
                .fill(color)
            }
        }
    }
}
