//
//  TripDetailsView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

struct TripDetailsView: View {
    @Binding var pin: Pin
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var dateError: String? = nil
    @State private var budgetText: String = ""

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing for better separation
                
                // Trip Dates Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Dates").font(.headline)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { _ in validateDates() }
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { _ in validateDates() }
                    if let dateError = dateError {
                        Text(dateError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))

                // Trip Rating Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Rating").font(.headline)
                    Slider(value: Binding(get: { Double(pin.tripRating ?? 0) }, set: { pin.tripRating = Int($0) }), in: 0...5, step: 1)
                        .padding(.horizontal)
                    HStack {
                        ForEach(0...5, id: \.self) { rating in
                            Text(rating == 0 ? "No Rating" : "\(rating)")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))

                // Trip Budget Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Cost").font(.headline)
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("Enter cost ($)", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: budgetText) { newValue in
                                budgetText = filterNumbersOnly(newValue)
                                if let budgetValue = Double(budgetText) {
                                    pin.tripBudget = budgetValue
                                }
                            }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
            }
            .padding()
        }
        .onAppear {
            // ✅ Only set start & end dates if they are nil, otherwise keep previous values
            startDate = pin.startDate ?? Date() // Use existing date if available
            endDate = pin.endDate ?? Date()

            if let budget = pin.tripBudget {
                budgetText = String(format: "%.2f", budget)
            }
        }
        .onDisappear {
            pin.startDate = startDate // Save selected date to pin
            pin.endDate = endDate
        }
    }

    private func validateDates() {
        dateError = startDate > endDate ? "❌ Start date cannot be after end date." : nil
    }

    /// Filters input to allow only numbers and one decimal point
    private func filterNumbersOnly(_ input: String) -> String {
        let filtered = input.filter { "0123456789.".contains($0) }
        let decimalCount = filtered.filter { $0 == "." }.count
        if decimalCount > 1 {
            return String(filtered.dropLast()) // Prevent multiple decimal points
        }
        return filtered
    }
}
