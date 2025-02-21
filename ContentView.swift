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
           let decoded = try? JSONDecoder().decode([Pin] .self, from: savedData) {
            self.pins = decoded
        }
    }
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
        span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 60.0)
    )

    @StateObject private var viewModel = PinsViewModel()
    @State private var selectedPin: Pin? = nil
    @State private var isEditingPin: Bool = false
    @State private var isSidebarOpen: Bool = false

    @State private var isJournalingPresented: Bool = false
    @State private var isSidebarPresented: Bool = false
    @State private var isSpotlightPresented: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            
            Color.black.opacity(0.9).ignoresSafeArea() // Set background to black

            HStack {
                if isSidebarOpen {
                    SidebarView(viewModel: viewModel, isSidebarOpen: $isSidebarOpen)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: isSidebarOpen)

                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25)) // Light gray divider
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.horizontal, 4)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome to Abroad")
                                .font(.largeTitle) // Increased from .title to .largeTitle
                                .bold()
                                .foregroundColor(.white)

                            Text("Pin your travels, reduce your footprint")
                                .font(.title2) // Increased from .subheadline to .title2
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 20)

                        Spacer()

                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation {
                                    isSidebarPresented = true
                                }
                            }) {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white) // Adjusted icon color
                            }

                            Button(action: {
                                isJournalingPresented.toggle()
                            }) {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white) // Adjusted icon color
                            }

                            Button(action: {
                                withAnimation {
                                    isSpotlightPresented = true
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white) // Adjusted icon color
                            }
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .foregroundColor(.white).opacity(0.88)

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
            
            if isSidebarPresented {
                SidebarModalView(isPresented: $isSidebarPresented, viewModel: viewModel)
                    .opacity(isSidebarPresented ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isSidebarPresented)
            }

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
                .onDisappear {
                    DispatchQueue.main.async {
                        selectedPin = nil // Reset selected pin after closing search
                    }
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("NavigateToPinEditView"), object: nil, queue: .main) { notification in
                if let pin = notification.object as? Pin {
                    DispatchQueue.main.async {
                        selectedPin = nil // Reset selection to avoid conflicts
                        selectedPin = pin
                        isEditingPin = true
                    }
                }
            }
        }
        .overlay(
                    Group {
                        if isEditingPin, let index = selectedPinIndex(), index < viewModel.pins.count {
                            ZStack {
                                Color.black.opacity(0.3)
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
                        
                        if isJournalingPresented {
                            JournalModalView(isPresented: $isJournalingPresented)
                                .opacity(isJournalingPresented ? 1 : 0) // Ensure full fade effect
                                .animation(.easeInOut(duration: 0.2), value: isJournalingPresented)
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

struct WelcomePanelView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome to Abroad, start your journey!")
                        .font(.headline)
                        .foregroundColor(.white) // Adjusted text color

                    Text("📍 Tap anywhere on the map to add a new location.")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.75)) // Darker background
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
