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
                "Use reef-safe sunscreen to protect marine ecosystems.",
                "Book stays at eco-lodges that use solar energy.",
                "Snorkel responsibly—do not touch or step on coral reefs.",
                "Support local fishermen by choosing sustainably sourced seafood.",
                "Carry a reusable water bottle to reduce plastic waste.",
                "Bring biodegradable toiletries to minimize pollution.",
                "Use electric or human-powered transport like bikes where possible.",
                "Join an eco-tour to learn about marine conservation.",
                "Pack out all trash, especially in remote island areas.",
                "Reduce water consumption—opt for quick showers over baths."
            ],
            packingList: [
                "Reef-safe sunscreen",
                "Biodegradable shampoo & conditioner",
                "Reusable water bottle with filter",
                "Lightweight, fast-drying clothing",
                "Eco-friendly insect repellent",
                "Solar-powered charger",
                "Reusable waterproof dry bag",
                "Snorkel gear (to avoid using rentals)",
                "Recycled or organic cotton beach towel",
                "Eco-friendly swimwear"
            ]
        ),
        SustainableTravelGuide(
            region: "Europe",
            coordinateRange: (35...70, -10...50),
            ecoTips: [
                "Travel by train—Europe has an excellent rail network.",
                "Stay in eco-certified hotels or sustainable Airbnbs.",
                "Choose locally-sourced vegetarian meals to cut carbon emissions.",
                "Bring a refillable bottle; many cities offer free public fountains.",
                "Walk, bike, or use public transport instead of renting a car.",
                "Carry a reusable coffee cup to cut down on single-use plastics.",
                "Avoid mass tourism spots and explore lesser-known sustainable destinations.",
                "Pack light to reduce airline emissions.",
                "Opt for digital travel documents instead of printing tickets.",
                "Shop for locally made souvenirs rather than mass-produced trinkets."
            ],
            packingList: [
                "Comfortable walking shoes",
                "Refillable water bottle with built-in filter",
                "Multi-use scarf for layering",
                "E-reader (to save paper books)",
                "Lightweight power bank",
                "Bamboo cutlery set for picnics",
                "Reusable produce bags for markets",
                "Collapsible, reusable coffee cup",
                "Digital transit pass or rail card",
                "Energy-efficient travel adapter"
            ]
        ),
        SustainableTravelGuide(
            region: "Australia & New Zealand",
            coordinateRange: (-50...0, 110...180),
            ecoTips: [
                "Explore national parks and Indigenous-led eco-tours.",
                "Choose electric or hybrid vehicles when road-tripping.",
                "Respect wildlife—keep a safe distance and avoid feeding animals.",
                "Use biodegradable soaps when camping in the outback.",
                "Stay in eco-certified accommodations with water conservation practices.",
                "Use a KeepCup or reusable coffee cup—coffee culture is strong here!",
                "Eat at farm-to-table restaurants supporting local producers.",
                "Reduce plastic use by bringing your own cutlery and containers.",
                "Go glamping instead of traditional resorts for an immersive nature experience.",
                "Support conservation efforts by visiting wildlife sanctuaries, not zoos."
            ],
            packingList: [
                "Wide-brim hat for sun protection",
                "Sustainable hiking boots",
                "Refillable insulated water bottle",
                "Merino wool clothing for temperature regulation",
                "Reef-safe sunscreen for the Great Barrier Reef",
                "Reusable snack pouches for road trips",
                "Compact reusable coffee cup",
                "Quick-dry, biodegradable travel towel",
                "Eco-friendly binoculars for wildlife spotting",
                "Rechargeable camping lantern"
            ]
        ),
        SustainableTravelGuide(
            region: "India & South Asia",
            coordinateRange: (5...35, 60...100),
            ecoTips: [
                "Take Indian Railways or public transport instead of domestic flights.",
                "Stay at eco-resorts or heritage homestays supporting local communities.",
                "Carry a filtered water bottle to avoid buying plastic bottles.",
                "Dress conservatively to respect cultural norms and reduce fast fashion waste.",
                "Shop at local markets instead of chain supermarkets.",
                "Try vegetarian or plant-based meals—South Asia has some of the best!",
                "Use a hand fan or cool cloth instead of air-conditioning.",
                "Refill reusable spice containers when buying at markets.",
                "Support ethical wildlife sanctuaries over animal tourism attractions.",
                "Reduce textile waste—buy handcrafted garments from artisans."
            ],
            packingList: [
                "Filtered water bottle",
                "Breathable cotton clothing",
                "Bamboo toothbrush & zero-waste toothpaste",
                "Multi-purpose scarf for covering shoulders",
                "Small hand fan for cooling",
                "Reusable stainless steel lunch box",
                "Lightweight, biodegradable laundry detergent sheets",
                "Reusable shopping tote",
                "Compostable wet wipes for hygiene",
                "Sustainable sandals for temple visits"
            ]
        ),
        SustainableTravelGuide(
            region: "North America",
            coordinateRange: (20...60, -130 ... -60),
            ecoTips: [
                "Visit national parks and follow Leave No Trace principles.",
                "Book eco-friendly hotels or sustainable tiny homes.",
                "Use car-sharing services or rent a hybrid/electric car.",
                "Reduce waste by packing a zero-waste travel kit.",
                "Take direct flights to cut down on carbon emissions.",
                "Support Indigenous-owned tourism experiences.",
                "Shop at local farmers' markets instead of big supermarkets.",
                "Opt for sustainable camping gear when exploring outdoors.",
                "Carry a reusable travel cutlery set to avoid plastic waste.",
                "Reduce energy use in hotels—turn off lights and AC when leaving."
            ],
            packingList: [
                "Zero-waste cutlery kit",
                "Portable solar charger",
                "Sustainable hiking boots",
                "Eco-friendly camping gear",
                "Reusable silicone food bags",
                "Packable, compostable trash bag for waste collection",
                "Bamboo toothbrush & toothpaste tabs",
                "Multi-purpose eco-friendly backpack",
                "Reusable snack pouch for road trips",
                "Collapsible, BPA-free water bottle"
            ]
        ),
        SustainableTravelGuide(
            region: "South America",
            coordinateRange: (-55...15, -80 ... -35),
            ecoTips: [
                "Stay in eco-lodges supporting rainforest conservation.",
                "Use public buses instead of flights when traveling between cities.",
                "Avoid buying souvenirs made from endangered species (like Amazonian wood carvings).",
                "Eat at family-owned restaurants that use seasonal, local ingredients.",
                "Join reforestation projects or community-based tourism experiences.",
                "Use biodegradable insect repellent to protect rainforest ecosystems.",
                "Learn about Indigenous cultures and traditions before visiting.",
                "Reduce plastic waste by bringing a reusable straw and utensils.",
                "Respect local wildlife—avoid petting or feeding wild animals.",
                "Support local guides for responsible Amazon rainforest tours."
            ],
            packingList: [
                "Mosquito-repellent clothing",
                "Refillable water filter bottle",
                "Waterproof, biodegradable sunscreen",
                "Reusable silicone snack bags",
                "Rainproof poncho made from recycled materials",
                "Hand-crank flashlight",
                "Quick-dry, odor-resistant clothing",
                "Organic cotton hammock (for jungle treks)",
                "Travel journal for ethical tourism reflections",
                "Portable coffee press for sustainable, fair-trade coffee"
            ]
        ),
        SustainableTravelGuide(
            region: "Africa",
            coordinateRange: (-35...37, -20...55),
            ecoTips: [
                "Choose safaris that follow responsible wildlife tourism practices.",
                "Stay in community-run eco-lodges that empower local tribes.",
                "Refill your water bottle at purification stations to reduce plastic use.",
                "Opt for sustainable safari gear made from recycled materials.",
                "Support local artisans by purchasing handmade crafts.",
                "Use biodegradable sunscreen to avoid polluting rivers and lakes.",
                "Minimize waste by bringing your own reusable hygiene products.",
                "Book eco-conscious experiences like rewilding projects or permaculture farms.",
                "Pack light to minimize fuel consumption during flights and safaris.",
                "Learn about the local ecosystem and conservation efforts before visiting."
            ],
            packingList: [
                "UV-protective, lightweight clothing",
                "Wide-brim sun hat",
                "Binoculars for ethical wildlife viewing",
                "Solar-powered charger",
                "Reusable bamboo utensils",
                "Portable water purifier",
                "Sustainable, all-terrain travel backpack",
                "Organic insect-repellent lotion",
                "Durable hiking sandals",
                "Eco-friendly dry shampoo bar"
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
