//
//  CategoryPickerView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: PinCategory
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Category").font(.headline)
                Picker("Category", selection: $selectedCategory) {
                    Text("Visited").tag(PinCategory.visited)
                    Text("Future Travel Plan").tag(PinCategory.future)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}
