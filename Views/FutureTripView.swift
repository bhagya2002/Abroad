//
//  FutureTripView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

struct FutureTripView: View {
    @Binding var pin: Pin
    @Binding var startDate: Date
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // ✅ Separate section for trip dates
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Text("📅 Trip Dates").font(.headline)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
            }
            .padding(.bottom, 10) // ✅ Adds spacing between sections

            // ✅ Separate section for sustainable travel tips
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Text("🌍 Sustainable Travel Tips for \(pin.ecoRegion ?? "this region")").font(.headline)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("♻️ **Eco-Friendly Tips:**").bold().padding(.bottom, 2)
                        ForEach(pin.ecoTips, id: \.self) { Text("• \($0)").foregroundColor(.gray).padding(.bottom, 2) }

                        Text("🎒 **Packing List:**").bold().padding(.top, 4)
                        ForEach(pin.packingList, id: \.self) { Text("• \($0)").foregroundColor(.gray) }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
            }
        }
        .onAppear {
            startDate = pin.startDate ?? Date()
            
            generateEcoTipsForPin()
        }
        .onDisappear {
            pin.startDate = startDate
        }
    }

    /// ✅ Generates and stores eco tips & packing list for the Pin **only once**
    private func generateEcoTipsForPin() {
        if pin.ecoRegion == nil || pin.ecoTips.isEmpty || pin.packingList.isEmpty {
            if let guide = SustainableTravelGuide.getGuide(for: (pin.coordinate.latitude, pin.coordinate.longitude)) {
                if pin.ecoRegion == nil {
                    pin.ecoRegion = guide.region // ✅ Store region name
                }
                if pin.ecoTips.isEmpty {
                    pin.ecoTips = guide.ecoTips.shuffled().prefix(5).map { $0 }
                }
                if pin.packingList.isEmpty {
                    pin.packingList = guide.packingList.shuffled().prefix(5).map { $0 }
                }
            }
        }
    }
}
