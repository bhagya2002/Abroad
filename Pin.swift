//
//  Pin.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import Foundation
import CoreLocation
import UIKit

enum PinCategory: String, Codable {
    case visited = "Visited"
    case future = "Future Travel Plan"
}

struct Pin: Identifiable, Codable {
    let id: UUID
    var title: String
    var coordinate: CLLocationCoordinate2D
    var category: PinCategory
    var photos: [Data]
    var startDate: Date? // ✅ Trip Start Date (Optional)
    var endDate: Date? // ✅ Trip End Date (Optional)
    var placesVisited: [String] // ✅ List of places (Optional, can be empty)
    var tripRating: Int? // ✅ Trip rating (1-5 stars)

    init(title: String, coordinate: CLLocationCoordinate2D, category: PinCategory, photos: [Data] = [], startDate: Date? = nil, endDate: Date? = nil, placesVisited: [String] = [], tripRating: Int? = nil) {
        self.id = UUID()
        self.title = title
        self.coordinate = coordinate
        self.category = category
        self.photos = photos
        self.startDate = startDate
        self.endDate = endDate
        self.placesVisited = placesVisited
        self.tripRating = tripRating
    }

    // MARK: - Encoding & Decoding CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, category, photos, startDate, endDate, placesVisited, tripRating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        category = try container.decode(PinCategory.self, forKey: .category)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        photos = try container.decode([Data].self, forKey: .photos)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        placesVisited = try container.decodeIfPresent([String].self, forKey: .placesVisited) ?? []
        tripRating = try container.decodeIfPresent(Int.self, forKey: .tripRating)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(category, forKey: .category)
        try container.encode(photos, forKey: .photos)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(placesVisited, forKey: .placesVisited)
        try container.encodeIfPresent(tripRating, forKey: .tripRating)
    }
}
