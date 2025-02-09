import SwiftUI
import MapKit

class PinsViewModel: ObservableObject {
    @Published var pins: [Pin] = [] {
        didSet {
            savePins()
        }
    }

    private let storageKey = "savedPins"

    init() {
        loadPins()
    }

    func savePins() {
        if let encoded = try? JSONEncoder().encode(pins) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func loadPins() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Pin].self, from: savedData) {
            self.pins = decoded
        }
    }
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Centered on North America
        span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 60.0) // Wider view
    )

    @StateObject private var viewModel = PinsViewModel()
    @State private var selectedPin: Pin? = nil
    @State private var isEditingPin: Bool = false
    @State private var isSidebarOpen: Bool = false // Track sidebar visibility

    // Spotlight Search States
    @State private var isSpotlightPresented: Bool = false
    @State private var searchText: String = ""
    @State private var selectedFilters: [String] = []

    var body: some View {
        ZStack {
            // Main App Layout
            HStack {
                // Sidebar integration
                if isSidebarOpen {
                    SidebarView(viewModel: viewModel, isSidebarOpen: $isSidebarOpen)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: isSidebarOpen)
                }

                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation { isSidebarOpen.toggle() }
                        }) {
                            Image(systemName: "sidebar.leading")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(isSidebarOpen ? Color(.systemGray4) : Color.clear)
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .foregroundColor(.primary)
                        .background(Color(.systemBackground))

                        EcoTipBannerView()
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                            .multilineTextAlignment(.center)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 15))

                        // Spotlight Search Button
                        Button(action: {
                            withAnimation {
                                isSpotlightPresented = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                                .padding(8)
                                .clipShape(Circle())
                                .padding(.horizontal, 15)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.1)

                    // Map Section
                    ZStack {
                        MapView(
                            region: $region,
                            pins: $viewModel.pins,
                            selectedPin: $selectedPin,
                            isEditingPin: $isEditingPin
                        )
                        .edgesIgnoringSafeArea(.all)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        // Welcome Panel
                        if viewModel.pins.isEmpty {
                            VStack {
                                WelcomePanelView()
                                Spacer()
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: viewModel.pins.isEmpty)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.85)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 15)
                    .cornerRadius(20)
                }
            }

            // Spotlight Search Overlay
            // Spotlight Search Overlay
            if isSpotlightPresented {
                SpotlightSearchView(
                    isPresented: $isSpotlightPresented,
                    searchText: $searchText,
                    selectedPin: $selectedPin,
                    region: $region,
                    pins: viewModel.pins
                )
                .transition(.opacity)
                .animation(.easeInOut, value: isSpotlightPresented)
            }

        }
        .overlay(
            Group {
                if isEditingPin, let index = selectedPinIndex(), index < viewModel.pins.count {
                    ZStack {
                        Color.black.opacity(0.3) // Background blur effect
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                handlePinDismiss(index: index)
                            }

                        PinEditView(
                            pin: $viewModel.pins[index],
                            isPresented: $isEditingPin,
                            deletePin: {
                                isEditingPin = false
                                selectedPin = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if index < viewModel.pins.count {
                                        viewModel.pins.remove(at: index)
                                    }
                                    viewModel.savePins()
                                }
                            },
                            startDate: Binding(
                                get: { viewModel.pins[index].startDate ?? Date() },
                                set: { viewModel.pins[index].startDate = $0 }
                            ),
                            endDate: Binding(
                                get: { viewModel.pins[index].endDate ?? Date() },
                                set: { viewModel.pins[index].endDate = $0 }
                            ),
                            viewModel: viewModel
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.5)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }
                    .transition(.scale)
                    .animation(.easeInOut, value: isEditingPin)
                }
            }
        )
    }

    private func selectedPinIndex() -> Int? {
        guard let selectedPin = selectedPin else { return nil }
        return viewModel.pins.firstIndex { $0.id == selectedPin.id }
    }

    private func handlePinDismiss(index: Int) {
        let pin = viewModel.pins[index]
        if pin.title.trimmingCharacters(in: .whitespaces).isEmpty &&
            pin.startDate == nil &&
            pin.endDate == nil &&
            pin.placesVisited.isEmpty {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if index < viewModel.pins.count {
                    viewModel.pins.remove(at: index)
                }
                viewModel.savePins()
            }
        }
        isEditingPin = false
    }
}

// ✅ Updated Welcome Panel View (No Longer Needs `pins` as a Parameter)
struct WelcomePanelView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome to Abroad, start your journey!")
                        .font(.headline)

                    Text("📍 Tap anywhere on the map to add a new location.")
                        .foregroundColor(.gray)
                }

                Spacer()

//                Button(action: {
//                    // Open add new pin
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.blue)
//                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
