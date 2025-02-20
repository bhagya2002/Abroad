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
            Color.black.opacity(0.3)
                    .ignoresSafeArea()

            Rectangle()
                .fill(Material.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            // Spotlight Search UI (Pill + Expanding Results)
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search Locations, Rating = 1-5, Category = Visited/Future Trip Plan...")
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .focused($isTextFieldFocused)
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
                .clipShape(RoundedCorner(radius: 20, corners: filteredPins.isEmpty ? .allCorners : [.topLeft, .topRight]))
                
                if !filteredPins.isEmpty {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 10)
                }

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
//                            .background(Color.black.opacity(0.65))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation {
                                    selectedPin = pin
                                    
                                    if abs(region.center.latitude - pin.coordinate.latitude) > 0.0001 ||
                                       abs(region.center.longitude - pin.coordinate.longitude) > 0.0001 {
                                        
                                        region = MKCoordinateRegion(
                                            center: pin.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                                        )
                                    }
                                    
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.90))
                    .clipShape(RoundedCorner(radius: 20, corners: filteredPins.isEmpty ? .allCorners : [.bottomLeft, .bottomRight]))

                }
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .onAppear {
                searchText = ""
            }
        }
        .onTapGesture {
            withAnimation {
                isPresented = false
            }
        }
        .ignoresSafeArea()
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

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
