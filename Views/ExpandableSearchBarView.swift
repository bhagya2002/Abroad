//
//  ExpandableSearchBarView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-09.
//


import SwiftUI

struct ExpandableSearchBarView: View {
    @Binding var isExpanded: Bool
    @Binding var searchText: String
    @Binding var selectedFilters: [String]
    @Binding var filteredPins: [Pin]

    let filters = ["Title", "Date", "Category", "Rating", "Emissions"]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isExpanded {
                    // Search Input Field
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: searchText) { _ in
                            applyFilters()
                        }
                    
                    // Filter Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(filters, id: \.self) { filter in
                                FilterTagView(
                                    filter: filter,
                                    isSelected: selectedFilters.contains(filter),
                                    onTap: { toggleFilter(filter) }
                                )
                            }
                        }
                    }
                }
                
                // Search Button
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                        if !isExpanded {
                            searchText = ""
                            selectedFilters.removeAll()
                            filteredPins = []
                        }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .frame(height: 40)
            .padding(.horizontal, isExpanded ? 10 : 0)
            .background(isExpanded ? Color(.systemGray5) : Color.clear)
            .cornerRadius(10)

            // Filtered Results (Expands Downward)
            if isExpanded && !filteredPins.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(filteredPins) { pin in
                        HStack {
                            Text(pin.title)
                                .font(.headline)
                                .lineLimit(1)
                            Spacer()
                            Text(pin.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .onTapGesture {
                            // Handle Pin Selection
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.removeAll { $0 == filter }
        } else {
            selectedFilters.append(filter)
        }
        applyFilters()
    }

    private func applyFilters() {
        filteredPins = PinsViewModel().filteredPins(searchText: searchText)
    }
}
