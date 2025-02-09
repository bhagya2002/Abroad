//
//  SharedViews.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-09.
//


import SwiftUI

struct FilterTagView: View {
    let filter: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(filter)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5))
            .foregroundColor(isSelected ? .blue : .gray)
            .cornerRadius(12)
            .onTapGesture {
                onTap()
            }
    }
}
