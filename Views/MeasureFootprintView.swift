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
        "Car 🚗": 0.18,    // 180g CO₂ per km
        "Bus 🚌": 0.08,    // 80g CO₂ per km
        "Bicycle 🚲": 0.0,  // 0g CO₂ per km
        "Walking 🚶": 0.0   // 0g CO₂ per km
    ]
}

struct MeasureFootprintView: View {
    @Binding var pin: Pin
    @State private var calculatedEmissions: [String: Double] = [:]
    @State private var showChart = false  // ✅ New state variable to control chart visibility

    let transportOptions = ["Plane ✈️", "Train 🚆", "Car 🚗", "Bus 🚌", "Bicycle 🚲", "Walking 🚶"]

    var totalEmissions: Double {
        return calculatedEmissions.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("✈️ 🚆 🚗 Measure Your Carbon Footprint")
                .font(.title2)
                .bold()
                .padding(.bottom, 10)

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

                            TextField("Distance (km)", text: $entry.distance)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: entry.distance) { _ in
                                    savePinData()
                                }

                            Button(action: {
                                removeEntry(entry)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Add transport mode button
                    Button(action: {
                        let newEntry = TransportEntry(id: UUID(), mode: "Plane ✈️", distance: "")
                        pin.transportEntries.append(newEntry)
                        savePinData()
                    }) {
                        Label("Add Transport", systemImage: "plus.circle")
                    }
                    .padding(.vertical, 5)
                }
            }
            .frame(maxHeight: 250)

            Button(action: {
                calculateFootprint()
                showChart = true  // ✅ Only show the chart after clicking this button
            }) {
                Text("Calculate Footprint")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            if showChart {  // ✅ The chart only appears after clicking the button
                VStack(alignment: .leading, spacing: 10) {
                    Text("🌍 Carbon Footprint Analysis")
                        .font(.headline)
                        .padding(.top, 10)

                    Text("Total Emissions: **\(String(format: "%.2f", totalEmissions)) kg CO₂**")
                        .font(.title3)
                        .foregroundColor(totalEmissions > 500 ? .red : totalEmissions > 100 ? .orange : .green)

                    if totalEmissions > 500 {
                        Text("🛑 Consider reducing flights and opting for trains.")
                            .foregroundColor(.gray)
                    } else if totalEmissions > 100 {
                        Text("🚆 Switching to trains could cut emissions significantly.")
                            .foregroundColor(.gray)
                    } else {
                        Text("✅ Great job! Your trip has a relatively low carbon footprint.")
                            .foregroundColor(.green)
                    }
                    
                    Chart {
                        ForEach(calculatedEmissions.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            BarMark(
                                x: .value("Transport", key),
                                y: .value("Emissions", value)
                            )
                            .foregroundStyle(value > 100 ? .red : .blue)
                        }
                    }
                    .frame(height: 250)
                }
                .padding()
            }
        }
        .padding()
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

    /// Saves transport data inside the pin (and to UserDefaults indirectly)
    func savePinData() {
        if let encoded = try? JSONEncoder().encode(pin) {
            UserDefaults.standard.set(encoded, forKey: "pin_\(pin.id.uuidString)")
        }
    }

    /// Removes an entry and updates storage
    func removeEntry(_ entry: TransportEntry) {
        pin.transportEntries.removeAll { $0.id == entry.id }
        savePinData()
    }
}
