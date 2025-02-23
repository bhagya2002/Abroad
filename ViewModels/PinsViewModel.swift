//
//  PinsViewModel.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-20.
//

import Foundation

extension PinsViewModel {
    func averageEfficiencyScore() -> Int {
        let scores = pins.compactMap { $0.travelEfficiencyScore }
        guard !scores.isEmpty else { return 0 }
        
        let totalScore = scores.reduce(0, +)
        let averageScore = totalScore / scores.count

        return averageScore
    }
}
