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
            
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Trip Dates").font(.headline)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .accentColor(.black)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
            }
            .padding(.bottom, 10)

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sustainable Travel Tips for \(pin.ecoRegion ?? "this region")")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("♻️ **Eco-Friendly Tips:**")
                            .bold()
                            .padding(.bottom, 2)
                        ForEach(pin.ecoTips, id: \.self) { tip in
                            Text("• \(tip)")
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                                .padding(.leading, 10)
                        }
                        
                        Spacer().frame(height: 12)
                        
                        Text("🎒 **Packing List:**")
                            .bold()
                            .padding(.bottom, 2)
                        ForEach(pin.packingList, id: \.self) { item in
                            Text("• \(item)")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
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

    private func generateEcoTipsForPin() {
        if pin.ecoRegion == nil || pin.ecoTips.isEmpty || pin.packingList.isEmpty {
            if let guide = SustainableTravelGuide.getGuide(for: (pin.coordinate.latitude, pin.coordinate.longitude)) {
                if pin.ecoRegion == nil {
                    pin.ecoRegion = guide.region
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
