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
        "Plane ✈️": 0.25,  // 250g CO₂ per km
        "Train 🚆": 0.041, // 41g CO₂ per km
        "Subway 🚇": 0.04, // 40g CO₂ per km
        "Car 🚗": 0.18,    // 180g CO₂ per km
        "Electric Car 🚙⚡": 0.05, // 50g CO₂ per km
        "Motorbike 🏍️": 0.10, // 100g CO₂ per km
        "Bus 🚌": 0.08,    // 80g CO₂ per km
        "Bicycle 🚲": 0.0,  // 0g CO₂ per km
        "Walking 🚶": 0.0,   // 0g CO₂ per km
        "Ferry ⛴️": 0.16,   // 160g CO₂ per km
        "Carpooling 🚗👥": 0.06 // 60g CO₂ per km
    ]
}

struct MeasureFootprintView: View {
    @Binding var pin: Pin
    @State private var calculatedEmissions: [String: Double] = [:]
    @State private var projectedSavings: Double = 0.0
    @State private var showChart = false

    let transportOptions = [
        "Plane ✈️", "Train 🚆", "Subway 🚇", "Car 🚗", "Electric Car 🚙⚡",
        "Motorbike 🏍️", "Bus 🚌", "Bicycle 🚲", "Walking 🚶", "Ferry ⛴️", "Carpooling 🚗👥"
    ]

    var totalEmissions: Double {
        return calculatedEmissions.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ✅ Title Section
            Text("🌱 Measure Your Carbon Footprint")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.top, 10)

            // ✅ Transport Input Section
            ScrollView {
                VStack(spacing: 15) {
                    ForEach($pin.transportEntries) { $entry in
                        HStack {
                            Picker("Mode", selection: $entry.mode) {
                                ForEach(transportOptions, id: \.self) { mode in
                                    Text(mode)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 140)

                            TextField("Distance (km)", text: $entry.distance)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                                .onChange(of: entry.distance) { _ in
                                    savePinData()
                                }

                            Button(action: { removeEntry(entry) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }

                    Button(action: {
                        let newEntry = TransportEntry(id: UUID(), mode: "Plane ✈️", distance: "")
                        pin.transportEntries.append(newEntry)
                        savePinData()
                    }) {
                        Label("Add Transport", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: 250)

            // ✅ Calculate Button
            Button(action: {
                calculateFootprint()
                calculateProjectedSavings()
                showChart = true
            }) {
                Text("Calculate Footprint")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            if showChart {
                VStack(alignment: .leading, spacing: 10) {
                    // ✅ Carbon Footprint Analysis Section
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
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                    // ✅ Eco-Friendly Savings Section
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }

                    // ✅ Emissions Chart
                    Chart {
                        ForEach(calculatedEmissions.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            BarMark(x: .value("Transport", key), y: .value("Emissions", value))
                                .foregroundStyle(value > 100 ? .red : .blue)
                        }
                    }
                    .frame(height: 250)

                    // ✅ Real-World Impact
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
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                }
                .padding()
            }
        }
        .padding()
    }

    // MARK: - Footprint Calculations

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
