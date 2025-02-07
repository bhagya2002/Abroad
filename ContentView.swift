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

    var body: some View {
        HStack {
            // ✅ Sidebar integration
            if isSidebarOpen {
                SidebarView(viewModel: viewModel, isSidebarOpen: $isSidebarOpen)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: isSidebarOpen)
            }

            VStack(spacing: 0) {
                // ✅ Top Navigation Bar
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
                        .padding(.trailing, 10)
                }
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .background(Color(.systemBackground))

                // ✅ Map Section
                ZStack {
                    MapView(region: $region, pins: $viewModel.pins, selectedPin: $selectedPin, isEditingPin: $isEditingPin)
                        .edgesIgnoringSafeArea(.all)
                }
                .frame(height: UIScreen.main.bounds.height * 0.85)
                .padding(.bottom, 15)
                .padding(.horizontal, 15)
                .cornerRadius(20)
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

#Preview {
    ContentView()
}
