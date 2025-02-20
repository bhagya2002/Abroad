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
                            createTravelEfficiencyScore()
                            createGlobalRankView()
                            createFlightImpactWarning()
                            createTransportModePieChart()
                            createTransportInsightsView()
                            createMostVisitedPlacesView()
                            createLocationsSummaryView()
                        }
                        .padding()
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.6)
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

        return VStack(alignment: .leading) {
            Text("Your Transport Breakdown")
                .font(.headline)
                .padding(.leading, 5)

            ZStack {
                ForEach(Array(transportData.enumerated()), id: \.offset) { index, data in
                    PieSliceView(
                        startAngle: angle(for: index, in: transportData),
                        endAngle: angle(for: index + 1, in: transportData),
                        color: colors[index % colors.count]
                    )
                }
            }
            .frame(width: 250, height: 250)

            Text("Total Transport Emissions: **\(Int(transportData.values.reduce(0, +))) kg CO₂**")
                .font(.subheadline)
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(transportData.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    HStack {
                        Circle()
                            .fill(colors[transportData.keys.sorted().firstIndex(of: key) ?? 0 % colors.count])
                            .frame(width: 10, height: 10)
                        Text("\(key): \(Int(value)) kg CO₂")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.leading, 5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createTravelEfficiencyScore() -> some View {
        let score = getTravelEfficiencyScore()

        return VStack {
            Text("📊 Travel Efficiency Score")
                .font(.headline)

            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(score) / 100)
                    .stroke(score > 70 ? Color.green : Color.orange, lineWidth: 12)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 100, height: 100)

                Text("\(score)%")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
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
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(getBestTransport())
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack {
                    Text("⚠️ Worst")
                        .font(.caption)
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

    private func createCarbonTrendsView() -> some View {
        VStack(alignment: .leading) {
            Text("📉 Your CO₂ Savings Over Time")
                .font(.headline)
            ChartView(savingsData: getSavingsOverTime())
                .frame(height: 150)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createEcoBadgesView() -> some View {
        VStack(alignment: .leading) {
            Text("🏆 Eco Badges Earned")
                .font(.headline)

            if getEcoBadges().isEmpty {
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
    
    private func createRealWorldImpactView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("🌱 Real-World Impact")
                .font(.headline)
            Text("🌳 **Trees Planted Equivalent:** \(getTreeEquivalent())")
            Text("🚗 **Cars Removed from Road:** \(getCarEquivalent())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createFlightImpactWarning() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("🛫 Flight Impact Warning")
                .font(.headline)
                .foregroundColor(.red)
            if let highestFlight = getHighestFlightImpact() {
                Text("Your **\(highestFlight) km** flight emitted the most CO₂.")
                Text("🚆 **Taking a train could have saved 80% CO₂!**")
                    .foregroundColor(.blue)
            } else {
                Text("✅ No recent high-emission flights detected!")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createGlobalRankView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("🌍 Your CO₂ vs. Global Travelers")
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
            Text("🌍 **Country:** \(getMostVisitedCountry())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
    
    private func createLocationsSummaryView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("📍 Travel Summary")
                .font(.headline)
            Text("📍 Locations Saved: **\(viewModel.pins.count)**")
            Text("✈️ Next Trip: **\(viewModel.pins.first(where: { $0.category == .future })?.title ?? "Plan one!")**")
            Text("🌱 CO₂ Saved: **\(calculateCarbonSavings()) kg**")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    // MARK: - Helper Functions

    private func calculateCarbonSavings() -> Double {
        return viewModel.pins.reduce(0) { $0 + ($1.tripBudget ?? 0) * 0.1 }
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
        return 2000 // Placeholder: Allow user to configure this
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

        if totalEmissions < 500 { badges.append("🌱 Carbon Saver - Emitted less than 500 kg CO₂") }
        if totalEmissions < 100 { badges.append("♻️ Green Traveler - Emitted less than 100 kg CO₂") }
        if totalEmissions > 1000 { badges.append("⚠️ High Carbon User - Over 1000 kg CO₂") }
        
        let trainTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Train 🚆" }
        if trainTrips.count >= 5 { badges.append("🚆 Train Enthusiast - 5+ train trips") }
        
        let walkingTrips = viewModel.pins.flatMap { $0.transportEntries }
            .filter { $0.mode == "Walking 🚶" }
        let walkingDistance = walkingTrips.reduce(0) { $0 + (Double($1.distance) ?? 0) }
        if walkingDistance > 50 { badges.append("🚶 Walking Hero - Walked 50+ km") }
        
        return badges
    }

    private func getSavingsOverTime() -> [Double] {
        return [50, 100, 200, 150, 300, 250] // Placeholder
    }
}
