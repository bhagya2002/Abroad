//
//  MeasureFootprintView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI
import Charts

struct CarbonEmissionFactors {
    static let emissionsPerKm: [String: Double] = [
        "Plane": 0.25,  // 250g CO₂ per km
        "Train": 0.041, // 41g CO₂ per km
        "Subway": 0.04, // 40g CO₂ per km
        "Car": 0.18,    // 180g CO₂ per km
        "Electric Car": 0.05, // 50g CO₂ per km
        "Motorbike": 0.10, // 100g CO₂ per km
        "Bus": 0.08,    // 80g CO₂ per km
        "Bicycle": 0.0,  // 0g CO₂ per km
        "Walking": 0.0,   // 0g CO₂ per km
        "Ferry": 0.16,   // 160g CO₂ per km
        "Carpooling": 0.06 // 60g CO₂ per km
    ]
}

struct MeasureFootprintView: View {
    @Binding var pin: Pin
    @State private var calculatedEmissions: [String: Double] = [:]
    @State private var projectedSavings: Double = 0.0
    @State private var travelEfficiencyScore: Int = 0
    @State private var showChart = false
    @State private var showAlert = false

    let transportOptions = [
        "Plane", "Train", "Subway", "Car", "Electric Car",
        "Motorbike", "Bus", "Bicycle", "Walking", "Ferry", "Carpooling"
    ]

    var totalEmissions: Double {
        return calculatedEmissions.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌱 Measure Your Carbon Footprint")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.top, 10)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach($pin.transportEntries) { $entry in
                        HStack(spacing: 12) {
                            Picker("Select Transport", selection: $entry.mode) {
                                Section(header: Text("✈️ Air Transport").font(.headline)) {
                                    Text("Plane").tag("Plane")
                                }
                                Section(header: Text("🚆 Land Transport").font(.headline)) {
                                    Text("Train").tag("Train")
                                    Text("Subway").tag("Subway")
                                    Text("Car").tag("Car")
                                    Text("Electric Car").tag("Electric Car")
                                    Text("Motorbike").tag("Motorbike")
                                    Text("Bus").tag("Bus")
                                    Text("Carpooling").tag("Carpooling")
                                    Text("Bicycle").tag("Bicycle")
                                    Text("Walking").tag("Walking")
                                }
                                Section(header: Text("⛴️ Water Transport").font(.headline)) {
                                    Text("Ferry").tag("Ferry")
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 180)
                            .accentColor(.white)

                            TextField("Distance (km)", text: $entry.distance)
                                .keyboardType(.decimalPad)
                                .padding()
                                .accentColor(.black)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: entry.distance) { newValue in
                                    var filtered = newValue.filter { "0123456789.".contains($0) }
                                    let dotCount = filtered.filter { $0 == "." }.count
                                    if dotCount > 1 {
                                        var result = ""
                                        var dotFound = false
                                        for char in filtered {
                                            if char == "." {
                                                if !dotFound {
                                                    result.append(char)
                                                    dotFound = true
                                                }
                                            } else {
                                                result.append(char)
                                            }
                                        }
                                        filtered = result
                                    }
                                    if filtered != newValue {
                                        entry.distance = filtered
                                    }
                                    savePinData()
                                }

                            Button(action: { removeEntry(entry) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Button(action: {
                        let newEntry = TransportEntry(id: UUID(), mode: "Walking", distance: "")
                        pin.transportEntries.append(newEntry)
                        savePinData()
                    }) {
                        Label("Add Transport", systemImage: "plus.circle")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 250)

            Button(action: {
                if validateDistances() {
                    calculateFootprint()
                    calculateProjectedSavings()
                    calculateTravelEfficiency()
                    showChart = true
                    
                    if !UserDefaults.standard.bool(forKey: "hasShownAnalysisNotification") {
                        NotificationCenter.default.post(name: NSNotification.Name("ShowAnalysisNotification"), object: nil)
                        UserDefaults.standard.set(true, forKey: "hasShownAnalysisNotification")
                    }
                } else {
                    showAlert = true
                }
            }) {
                Text("Calculate Footprint")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please enter distances for all transport entries."),
                      dismissButton: .default(Text("OK")))
            }

            if showChart {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("🌍 Carbon Footprint Analysis")
                            .font(.headline)
                            .padding(.top, 10)

                        Text("Total Emissions: **\(String(format: "%.2f", totalEmissions)) kg CO₂**")
                            .font(.title3)
                            .foregroundColor(totalEmissions > 500 ? .red : totalEmissions > 100 ? .orange : .green)

                        Text(totalEmissions > 500 ?
                            "🛑 High emissions! Consider using trains instead of flights." :
                            totalEmissions > 100 ?
                            "🚆 Switching to trains could significantly lower your footprint." :
                            "✅ Great job! Your trip is eco-friendly."
                        )
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.black)))

                    if projectedSavings > 0 {
                        VStack(alignment: .leading) {
                            Text("💡 Eco-Friendly Alternative")
                                .font(.headline)
                            Text("If you chose a **train instead of a flight**, you would save **\(String(format: "%.1f", projectedSavings)) kg CO₂!**")
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.black)))
                    }

                    Chart {
                        ForEach(calculatedEmissions.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            BarMark(x: .value("Transport", key), y: .value("Emissions", value))
                                .foregroundStyle(value > 100 ? .red : .blue)
                        }
                    }
                    .frame(height: 250)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.black)))

                    VStack(alignment: .leading) {
                        Text("🌱 Real-World Impact")
                            .font(.headline)
                        Text("🌳 Your carbon savings equal **planting \(Int(totalEmissions / 20)) trees!**")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("🚗 Equivalent to **removing \(Int(totalEmissions / 2)) cars from the road for a day!**")
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.black)))
                    
                    displayCarbonOffsetRecommendations()
                }
                .padding()
            }
        }
        .padding()
    }

    // MARK: - Footprint Calculations
    
    func validateDistances() -> Bool {
        for entry in pin.transportEntries {
            if entry.distance.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }
        return true
    }

    func calculateFootprint() {
        var newEmissions: [String: Double] = [:]
        for entry in pin.transportEntries {
            if let distanceValue = Double(entry.distance),
               let emissionFactor = CarbonEmissionFactors.emissionsPerKm[entry.mode] {
                newEmissions[entry.mode] = (newEmissions[entry.mode] ?? 0) + (distanceValue * emissionFactor)
            }
        }
        calculatedEmissions = newEmissions
    }

    func calculateProjectedSavings() {
        projectedSavings = 0.0
        for entry in pin.transportEntries {
            if let distanceValue = Double(entry.distance),
               let currentEmission = CarbonEmissionFactors.emissionsPerKm[entry.mode] {
                if entry.mode == "Plane ✈️", let trainEmission = CarbonEmissionFactors.emissionsPerKm["Train 🚆"] {
                    projectedSavings += (currentEmission - trainEmission) * distanceValue
                }
            }
        }
    }

    func calculateTravelEfficiency() {
        let goodModes = ["Train", "Subway", "Bicycle", "Walking", "Bus"]
        let badModes = ["Plane", "Car", "Motorbike", "Ferry"]

        let ecoTrips = pin.transportEntries.filter { goodModes.contains($0.mode) }.count
        let highEmissionTrips = pin.transportEntries.filter { badModes.contains($0.mode) }.count

        travelEfficiencyScore = max(0, 100 - (highEmissionTrips * 5) + (ecoTrips * 3))
        travelEfficiencyScore = min(travelEfficiencyScore, 100)
    }

    func displayCarbonOffsetRecommendations() -> some View {
        let treesNeeded = totalEmissions / 20
        let offsetCost = totalEmissions * 0.02

        return VStack(alignment: .leading) {
            Text("🌳 Carbon Offset Recommendations")
                .font(.headline)
            Text("To offset this trip, plant **\(Int(treesNeeded)) trees**.")
            Text("💰 Cost to offset: **$\(String(format: "%.2f", offsetCost))**")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.black)))
    }

    func savePinData() {
        if let encoded = try? JSONEncoder().encode(pin) {
            UserDefaults.standard.set(encoded, forKey: "pin_\(pin.id.uuidString)")
        }
    }

    func removeEntry(_ entry: TransportEntry) {
        pin.transportEntries.removeAll { $0.id == entry.id }
        savePinData()
    }
}
