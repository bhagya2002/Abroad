//
//  Pin.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import Foundation
import CoreLocation

struct TransportEntry: Identifiable, Codable {
    let id: UUID
    var mode: String
    var distance: String
}

enum PinCategory: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case visited = "Visited"
    case future = "Future Travel Plan"
    
    var id: String { self.rawValue }
}

struct Pin: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var coordinate: CLLocationCoordinate2D
    var category: PinCategory
    var startDate: Date?
    var endDate: Date?
    var placesVisited: [String]
    var tripRating: Int?
    var tripBudget: Double?
    
    var imageFilenames: [String]
    
    var transportEntries: [TransportEntry]
    
    var icon: String = "📍"
    
    var ecoTips: [String]
    var packingList: [String]
    var ecoRegion: String?
    
    var travelEfficiencyScore: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "efficiencyScore_\(id.uuidString)")
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: "efficiencyScore_\(id.uuidString)")
            } else {
                UserDefaults.standard.removeObject(forKey: "efficiencyScore_\(id.uuidString)")
            }
        }
    }
    
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.id == rhs.id // Compare by unique ID
    }

    // MARK: - Initializers
    init(
        id: UUID = UUID(),
        title: String = "",
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        category: PinCategory = .visited,
        startDate: Date? = nil,
        endDate: Date? = nil,
        placesVisited: [String] = [],
        tripRating: Int? = nil,
        tripBudget: Double? = nil,
        ecoRegion: String? = nil,
        ecoTips: [String] = [],
        packingList: [String] = [],
        imageFilenames: [String] = [],
        transportEntries: [TransportEntry] = [],
        icon: String = ""
    ) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.placesVisited = placesVisited
        self.tripRating = tripRating
        self.tripBudget = tripBudget
        self.ecoRegion = ecoRegion
        self.ecoTips = ecoTips
        self.packingList = packingList
        self.imageFilenames = imageFilenames
        self.transportEntries = transportEntries
        self.icon = icon
    }

    // MARK: - Computed Properties
    var tripDuration: Int? {
        guard let start = startDate, let end = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: start, to: end).day
    }

    var hasValidTripDates: Bool {
        guard let start = startDate, let end = endDate else { return false }
        return start < end
    }

    // MARK: - Encoding & Decoding CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, category, startDate, endDate, placesVisited, tripRating, tripBudget, icon
        case ecoRegion, ecoTips, packingList, imageFilenames, transportEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        category = try container.decode(PinCategory.self, forKey: .category)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        placesVisited = try container.decodeIfPresent([String].self, forKey: .placesVisited) ?? []
        tripRating = try container.decodeIfPresent(Int.self, forKey: .tripRating)
        tripBudget = try container.decodeIfPresent(Double.self, forKey: .tripBudget)
        ecoRegion = try container.decodeIfPresent(String.self, forKey: .ecoRegion)
        ecoTips = try container.decodeIfPresent([String].self, forKey: .ecoTips) ?? []
        packingList = try container.decodeIfPresent([String].self, forKey: .packingList) ?? []
        imageFilenames = try container.decodeIfPresent([String].self, forKey: .imageFilenames) ?? []
        transportEntries = try container.decodeIfPresent([TransportEntry].self, forKey: .transportEntries) ?? []
        icon = try container.decode(String.self, forKey: .icon)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(placesVisited, forKey: .placesVisited)
        try container.encodeIfPresent(tripRating, forKey: .tripRating)
        try container.encodeIfPresent(tripBudget, forKey: .tripBudget)
        try container.encodeIfPresent(ecoRegion, forKey: .ecoRegion)
        try container.encode(ecoTips, forKey: .ecoTips)
        try container.encode(packingList, forKey: .packingList)
        try container.encode(imageFilenames, forKey: .imageFilenames)
        try container.encode(transportEntries, forKey: .transportEntries)
        try container.encode(icon, forKey: .icon)
    }
}
