//
//  SustainableTravelGuide.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//


import Foundation

struct SustainableTravelGuide {
    let region: String
    let coordinateRange: (latitude: ClosedRange<Double>, longitude: ClosedRange<Double>)
    let ecoTips: [String]
    let packingList: [String]

    static let guides: [SustainableTravelGuide] = [
        SustainableTravelGuide(
            region: "Tropical",
            coordinateRange: (-10...25, -180...180),
            ecoTips: [
                "Use reef-safe sunscreen to protect marine life.",
                "Stay in eco-friendly beachfront resorts.",
                "Support local sustainable seafood restaurants.",
                "Avoid using single-use plastics while at the beach.",
                "Respect wildlife by keeping a safe distance.",
                "Use a bamboo toothbrush to reduce plastic waste.",
                "Opt for solar-powered chargers for devices.",
                "Participate in local beach clean-ups.",
                "Choose locally-made souvenirs instead of mass-produced ones.",
                "Use eco-friendly mosquito repellents to protect local ecosystems."
            ],
            packingList: [
                "Reef-safe sunscreen",
                "Light, breathable clothing",
                "Reusable water bottle",
                "Eco-friendly insect repellent",
                "Biodegradable toiletries",
                "Solar-powered phone charger",
                "Reusable shopping bag",
                "Waterproof sandals",
                "Organic cotton beach towel",
                "Eco-friendly laundry detergent sheets"
            ]
        ),
        SustainableTravelGuide(
            region: "Europe",
            coordinateRange: (35...70, -10...50),
            ecoTips: [
                "Travel by train instead of short-haul flights.",
                "Stay at eco-certified hotels.",
                "Use a reusable tote bag for shopping.",
                "Choose plant-based meal options where possible.",
                "Respect cultural heritage by following local guidelines.",
                "Carry a reusable coffee cup to reduce waste.",
                "Choose public transportation over rental cars.",
                "Stay in sustainable Airbnbs or eco-friendly hostels.",
                "Use digital tickets to avoid unnecessary printing.",
                "Pack reusable cutlery and a cloth napkin for meals on the go."
            ],
            packingList: [
                "Comfortable walking shoes",
                "Reusable coffee cup",
                "Public transportation card",
                "Layered clothing for varying weather",
                "Eco-friendly toiletries",
                "Portable bamboo cutlery set",
                "Foldable reusable shopping bag",
                "Refillable perfume/cologne bottle",
                "Zero-waste shampoo bar",
                "Energy-efficient travel adapter"
            ]
        ),
        SustainableTravelGuide(
            region: "Australia & New Zealand",
            coordinateRange: (-50...0, 110...180),
            ecoTips: [
                "Choose eco-tourism activities like wildlife sanctuaries.",
                "Use public transport instead of renting a car.",
                "Respect Indigenous cultural sites and traditions.",
                "Carry a reusable water bottle to reduce waste.",
                "Stay in certified eco-lodges.",
                "Be mindful of your energy consumption in accommodations.",
                "Avoid using single-use coffee cups—bring your own mug.",
                "Use reef-safe sunscreen while snorkeling.",
                "Reduce food waste by ordering smaller portions or sharing meals.",
                "Walk or bike instead of using taxis for short distances."
            ],
            packingList: [
                "Eco-friendly sunscreen",
                "Reusable shopping bag",
                "Hiking boots for outdoor adventures",
                "Warm clothing for cooler regions",
                "Refillable water bottle",
                "Merino wool travel socks (odor-resistant)",
                "Lightweight, reusable camping utensils",
                "Solar-powered flashlight",
                "Refillable silicone travel bottles",
                "Waterproof eco-friendly jacket"
            ]
        ),
        SustainableTravelGuide(
            region: "India & South Asia",
            coordinateRange: (5...35, 60...100),
            ecoTips: [
                "Use public transport like trains and tuk-tuks instead of taxis.",
                "Stay at heritage homestays to support local businesses.",
                "Avoid using plastic bottled water; bring a filtered bottle.",
                "Dress modestly to respect local customs.",
                "Support local markets instead of international chains.",
                "Try vegetarian or vegan street food to minimize carbon footprint.",
                "Use a hand fan instead of electric cooling devices in moderate weather.",
                "Respect wildlife by avoiding elephant rides and tiger selfies.",
                "Minimize waste by carrying your own reusable utensils.",
                "Choose hotels that follow responsible tourism practices."
            ],
            packingList: [
                "Light, breathable clothing",
                "Filtered water bottle",
                "Scarf or shawl for temple visits",
                "Hand sanitizer",
                "Local currency for small vendors",
                "Bamboo cutlery set",
                "Reusable face mask",
                "Refillable spice container for street food lovers",
                "Eco-friendly laundry detergent strips",
                "Foldable travel tote for markets"
            ]
        ),
        SustainableTravelGuide(
            region: "North America",
            coordinateRange: (20...60, -130 ... -60),
            ecoTips: [
                "Book accommodations with high energy efficiency ratings.",
                "Rent hybrid or electric vehicles when possible.",
                "Use car-sharing services instead of renting a personal car.",
                "Respect national park guidelines and avoid disturbing wildlife.",
                "Minimize flight emissions by booking non-stop flights.",
                "Pack a zero-waste travel kit.",
                "Opt for local, seasonal foods to reduce transport emissions.",
                "Bring an e-reader instead of paper books to save space and weight.",
                "Turn off hotel appliances when leaving the room.",
                "Recycle or properly dispose of waste according to local regulations."
            ],
            packingList: [
                "Compact reusable grocery bags",
                "Zero-waste travel cutlery set",
                "High-SPF reef-safe sunscreen",
                "Energy-efficient travel adapter",
                "Digital guidebook (instead of paper maps)",
                "Collapsible stainless steel straw",
                "Reusable Ziploc-style silicone bags",
                "Biodegradable wipes",
                "Compact solar power bank",
                "Organic cotton travel pillowcase"
            ]
        )
    ]

    /// Returns a guide for the given coordinates
        static func getGuide(for coordinate: (latitude: Double, longitude: Double)) -> SustainableTravelGuide? {
            return guides.first(where: {
                $0.coordinateRange.latitude.contains(coordinate.latitude) &&
                $0.coordinateRange.longitude.contains(coordinate.longitude)
            })
        }
    }
