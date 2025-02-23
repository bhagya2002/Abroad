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
        // Reset the analysis notification flag when there are no pins.
        if pins.isEmpty {
            UserDefaults.standard.set(false, forKey: "hasShownAnalysisNotification")
        }
    }

    func loadPins() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Pin].self, from: savedData) {
            self.pins = decoded
        }
    }
}

struct CarbonFootprintProgressBar: View {
    @ObservedObject var viewModel: PinsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
//            Text("Your maximum carbon emission allowance")
//                .font(.headline)
            HStack {
                Text("Max carbon emission goal")
                    .font(.headline)
                    .foregroundColor(.white)
                ProgressView(value: getTotalEmissions(), total: getUserCarbonGoal())
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 10)
                    .accentColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // makes the view span the full width
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black))
        .padding(.horizontal)
    }
    
    func getTotalEmissions() -> Double {
        viewModel.pins.flatMap { $0.transportEntries }
            .compactMap { entry in
                let emissionFactor = CarbonEmissionFactors.emissionsPerKm[entry.mode] ?? 0
                return (Double(entry.distance) ?? 0) * emissionFactor
            }
            .reduce(0, +)
    }
    
    func getUserCarbonGoal() -> Double {
        // Replace with your own logic or property; for now, using a constant.
        return 5000.0
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
    
    @State private var showAnalysisNotification: Bool = false
    @State private var isHowToUsePresented: Bool = false

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
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)

                            Text("Pin your travels, reduce your carbon footprint")
                                .font(.title2)
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
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                isJournalingPresented.toggle()
                            }) {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }

                            Button(action: {
                                withAnimation {
                                    isSpotlightPresented = true
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .foregroundColor(.white).opacity(0.88)
                    
                    CarbonFootprintProgressBar(viewModel: viewModel)
                        .padding(.vertical, 10)

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
                        
                        if !viewModel.pins.isEmpty && showAnalysisNotification {
                            VStack {
                                AnalysisNotificationView()
                                    .onTapGesture {
                                        withAnimation {
                                            showAnalysisNotification = false
                                        }
                                    }
                                Spacer()
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: showAnalysisNotification)
                        }
                        
                        if isHowToUsePresented {
                            HowToUseAppModalView(isPresented: $isHowToUsePresented)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.2), value: isHowToUsePresented)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.83)
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
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowAnalysisNotification"), object: nil, queue: .main) { _ in
                    Task { @MainActor in
                        withAnimation {
                            showAnalysisNotification = true
                        }
                    }
                }
                
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
                        .opacity(isJournalingPresented ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isJournalingPresented)
                }
            }
        )
        .overlay(
            Group {
                if !isSidebarPresented && !isJournalingPresented && !isSpotlightPresented {
                    VStack(spacing: 16) {
                        Button(action: {
                            zoomIn()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(Color(UIColor.black))
                                .clipShape(Circle())
                        }
                        Button(action: {
                            zoomOut()
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(Color(UIColor.black))
                                .clipShape(Circle())
                        }
                        // New "How to Use" button
                        Button(action: {
                            isHowToUsePresented = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(Color(UIColor.black))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.trailing, 40)
                }
            },
            alignment: .bottomTrailing
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
    
    // MARK: - Zoom Control Methods
    private func zoomIn() {
        let minLatitudeDelta: CLLocationDegrees = 0.005
        let minLongitudeDelta: CLLocationDegrees = 0.005
        let newLatitudeDelta = max(region.span.latitudeDelta / 2.0, minLatitudeDelta)
        let newLongitudeDelta = max(region.span.longitudeDelta / 2.0, minLongitudeDelta)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }

    private func zoomOut() {
        let maxLatitudeDelta: CLLocationDegrees = 180.0
        let maxLongitudeDelta: CLLocationDegrees = 360.0
        let newLatitudeDelta = min(region.span.latitudeDelta * 3.0, maxLatitudeDelta)
        let newLongitudeDelta = min(region.span.longitudeDelta * 3.0, maxLongitudeDelta)
        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
    }
}

struct WelcomePanelView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("📍 Get started with your journey!")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("      Tap anywhere on the map to add a new location.")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
    }
}

struct AnalysisNotificationView: View {
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Check the chart icon for an analysis of your travels!")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
