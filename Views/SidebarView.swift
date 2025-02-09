//
//  SidebarView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-07.
//


import SwiftUI
import Charts

struct SidebarView: View {
    @ObservedObject var viewModel: PinsViewModel
    @Binding var isSidebarOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // ✅ Sidebar Header
            HStack {
                Text("My Travel Insights")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading, 20)
            }
            .padding(.top, 55)

            ScrollView {
                VStack(spacing: 20) {
                    createCarbonProgressView()
                    createTransportInsightsView()
                    createCarbonTrendsView()
                    createEcoBadgesView()
                    createRealWorldImpactView()
                    createFlightImpactWarning()
                    createGlobalRankView()
                    createMostVisitedPlacesView()
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("📍 Locations Saved: **\(viewModel.pins.count)**")
                            Text("✈️ Next Trip: **\(viewModel.pins.first(where: { $0.category == .future })?.title ?? "Plan one!")**")
                            Text("🌱 CO₂ Saved: **\(calculateCarbonSavings()) kg**")
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
        .frame(width: 500)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.vertical)
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
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createEcoBadgesView() -> some View {
        VStack(alignment: .leading) {
            Text("🏆 Eco Badges Earned")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(getEcoBadges(), id: \.self) { badge in
                        Text(badge)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.3)))
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createRealWorldImpactView() -> some View {
        VStack(alignment: .leading) {
            Text("🌱 Real-World Impact")
                .font(.headline)
            Spacer()
            Text("🌳 **Trees Planted Equivalent:** \(getTreeEquivalent())")
            Text("🚗 **Cars Removed from Road:** \(getCarEquivalent())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Forces full width
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createFlightImpactWarning() -> some View {
        VStack(alignment: .leading) {
            Text("🛫 Flight Impact Warning")
                .font(.headline)
                .foregroundColor(.red)
            Spacer()
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
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Forces full width
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createGlobalRankView() -> some View {
        VStack(alignment: .leading) {
            Text("🌍 Your CO₂ vs. Global Travelers")
                .font(.headline)
            Spacer()
            Text("Your emissions are **\(getGlobalRank())% better** than the average traveler!")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Forces full width
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }

    private func createMostVisitedPlacesView() -> some View {
        VStack(alignment: .leading) {
            Text("📌 Most Visited Places")
                .font(.headline)
            Spacer()
            Text("🏙️ **City:** \(getMostVisitedCity())")
            Text("🌍 **Country:** \(getMostVisitedCountry())")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Forces full width
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
        return max(0, Int(getTotalEmissions() / co2PerTree)) // ✅ Prevents negative values
    }

    private func getCarEquivalent() -> Int {
        let co2PerCar = 2.3 // 2.3kg CO₂ per liter of gasoline burned
        return max(0, Int(getTotalEmissions() / co2PerCar)) // ✅ Prevents negative values
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

        if userEmissions == 0 { return 100 } // ✅ If no emissions, user is in top 100%
        
        let rank = 100 - ((userEmissions / globalAverageEmissions) * 100)
        return max(0, min(Int(rank), 100)) // ✅ Ensures values stay between 0% - 100%
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
            if let country = pin.ecoRegion { // ✅ Uses `ecoRegion` to determine the country
                counts[country, default: 0] += 1
            }
        }
        return countryCounts.max(by: { $0.value < $1.value })?.key ?? "Unknown"
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

// ✅ ChartView for CO₂ Savings
struct ChartView: View {
    var savingsData: [Double]

    var body: some View {
        Chart {
            ForEach(savingsData.indices, id: \.self) { index in
                LineMark(
                    x: .value("Month", index),
                    y: .value("CO₂ Saved", savingsData[index])
                )
            }
        }
    }
}
