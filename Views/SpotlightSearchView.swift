//
//  SpotlightSearchView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-09.
//

import SwiftUI
import MapKit

struct SpotlightSearchView: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @Binding var selectedPin: Pin?
    @Binding var region: MKCoordinateRegion
    @State private var filteredPins: [Pin] = []
    
    @FocusState private var isTextFieldFocused: Bool

    let pins: [Pin]

    var body: some View {
        ZStack {
            // Subtle Background Blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(Material.ultraThinMaterial)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Spotlight Search UI (Pill + Expanding Results)
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search Locations, Rating = 1-5, Category...")
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .focused($isTextFieldFocused) // ✅ Auto-focus when opened
                        .onAppear { isTextFieldFocused = true }
                        .cornerRadius(10)
                        .onChange(of: searchText) { _ in
                            applyFilters()
                        }

                    Button(action: {
                        withAnimation {
                            isPresented = false
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))
                .cornerRadius(20)

                // Search Results
                if !filteredPins.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredPins) { pin in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(pin.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(pin.category.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation {
                                    selectedPin = pin
                                    
                                    // ✅ Check if region update is needed to avoid unnecessary redraws
                                    if abs(region.center.latitude - pin.coordinate.latitude) > 0.0001 ||
                                       abs(region.center.longitude - pin.coordinate.longitude) > 0.0001 {
                                        
                                        region = MKCoordinateRegion(
                                            center: pin.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15) // ✅ More zoomed-out than before
                                        )
                                    }
                                    
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.65))
                    .cornerRadius(20)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .onAppear {
                searchText = "" // ✅ Clears search bar every time Spotlight opens
            }
        }
    }

    // MARK: - Filtering Logic
    private func applyFilters() {
        filteredPins = PinsViewModel().filteredPins(searchText: searchText)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        placeholder: @escaping () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
