//
//  EcoTipBannerView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI

struct EcoTipBannerView: View {
    let ecoTips = [
        "Use public transport instead of renting a car.",
        "Bring a reusable water bottle to reduce plastic waste.",
        "Choose eco-friendly accommodations with sustainability policies.",
        "Support local businesses and markets when traveling.",
        "Pack light to reduce fuel consumption on flights.",
        "Opt for digital tickets instead of printing them.",
        "Respect local wildlife and avoid animal tourism.",
        "Stay at eco-certified hotels or hostels.",
        "Eat at local plant-based restaurants when possible.",
        "Turn off hotel lights and air conditioning when leaving.",
        "Offset your carbon footprint by donating to green initiatives.",
        "Travel by train or bus instead of taking short-haul flights.",
        "Use biodegradable toiletries and reef-safe sunscreen.",
        "Reduce food waste by ordering only what you can eat.",
        "Choose walking or cycling to explore destinations."
    ]
    
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Text(ecoTips[currentIndex])
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: geo.size.width - 20) // ✅ Full-width, no fixed height
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.black) // ✅ Black text for readability
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .onAppear {
                        startAutoScroll()
                    }
            }
            .frame(maxWidth: .infinity) // ✅ Ensures it stretches across the screen
        }
    }

    private func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation {
                    currentIndex = (currentIndex + 1) % ecoTips.count
                }
            }
        }
    }
}
