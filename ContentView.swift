import SwiftUI
import MapKit

// MARK: - View Model

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

// MARK: - Carbon Footprint Progress Bar

struct CarbonFootprintProgressBar: View {
    @ObservedObject var viewModel: PinsViewModel
    @AppStorage("userCarbonGoal") var userCarbonGoal: Double = 5000.0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Max carbon emission goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
                ProgressView(value: getTotalEmissions(), total: getUserCarbonGoal())
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 10)
                    .accentColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
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
        return userCarbonGoal
    }
}

// MARK: - Main Content View

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
    
    // Welcome popup state and first-launch flag
    @State private var isWelcomePopupPresented: Bool = false
    @AppStorage("hasSeenWelcomePopup") var hasSeenWelcomePopup: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            HStack {
                if isSidebarOpen {
                    SidebarView(viewModel: viewModel, isSidebarOpen: $isSidebarOpen)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut, value: isSidebarOpen)

                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                    .padding(.horizontal, 4)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Abroad")
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
                                withAnimation { isSidebarPresented = true }
                            }) {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            Button(action: { isJournalingPresented.toggle() }) {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                withAnimation { isSpotlightPresented = true }
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
                                        withAnimation { showAnalysisNotification = false }
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
                    DispatchQueue.main.async { selectedPin = nil }
                }
            }
            
            // Welcome Popup Overlay
            if isWelcomePopupPresented {
                ZStack {
                    Color.black.opacity(0.955).edgesIgnoringSafeArea(.all)
                    WelcomePopupView(isPresented: $isWelcomePopupPresented)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isWelcomePopupPresented)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowAnalysisNotification"), object: nil, queue: .main) { _ in
                Task { @MainActor in
                    withAnimation { showAnalysisNotification = true }
                }
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("NavigateToPinEditView"), object: nil, queue: .main) { notification in
                if let pin = notification.object as? Pin {
                    DispatchQueue.main.async {
                        selectedPin = nil
                        selectedPin = pin
                        isEditingPin = true
                    }
                }
            }
            if !hasSeenWelcomePopup {
                isWelcomePopupPresented = true
            }
        }
        .onChange(of: isWelcomePopupPresented) { newValue in
            if newValue == false {
                hasSeenWelcomePopup = true
            }
        }
        .overlay(
            Group {
                if isEditingPin, let index = selectedPinIndex(), index < viewModel.pins.count {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture { handlePinDismiss(index: index) }
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
                if !isSidebarPresented && !isJournalingPresented && !isSpotlightPresented && !isHowToUsePresented && !isWelcomePopupPresented {
                    VStack(spacing: 16) {
                        Button(action: { zoomIn() }) {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(Color(UIColor.black))
                                .clipShape(Circle())
                        }
                        Button(action: { zoomOut() }) {
                            Image(systemName: "minus")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(Color(UIColor.black))
                                .clipShape(Circle())
                        }
                        Button(action: { isHowToUsePresented = true }) {
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
    
    // MARK: - Zoom Controls
    private func zoomIn() {
        let minDelta: CLLocationDegrees = 0.005
        region.span = MKCoordinateSpan(
            latitudeDelta: max(region.span.latitudeDelta / 2.0, minDelta),
            longitudeDelta: max(region.span.longitudeDelta / 2.0, minDelta)
        )
    }

    private func zoomOut() {
        let maxLatDelta: CLLocationDegrees = 180.0
        let maxLongDelta: CLLocationDegrees = 360.0
        region.span = MKCoordinateSpan(
            latitudeDelta: min(region.span.latitudeDelta * 3.0, maxLatDelta),
            longitudeDelta: min(region.span.longitudeDelta * 3.0, maxLongDelta)
        )
    }
}

// MARK: - Welcome Popup View

// Renamed extension for custom placeholder styling in SwiftUI
extension View {
    func customPlaceholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct WelcomePopupView: View {
    @Binding var isPresented: Bool
    @AppStorage("userCarbonGoal") var userCarbonGoal: Double = 5000.0
    @State private var tempCarbonGoal: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Welcome to Abroad")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
            Divider()
                .background(Color.white)
            
            // Importance of Sustainable Travel
            Text("""
Traveling is about adventure, culture, and new experiences—but it also impacts our planet.
""")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("""
The transportation sector accounts for **25% of global CO₂ emissions**, with aviation alone contributing **2.5%**. A single long-haul flight can emit **more CO₂ than some people produce in a year**.
""")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Real-World Travel Impact Examples
            Text("""
✈️ **California to Europe:** ~1,500 kg CO₂ (round trip)  
🚗 **Cross-country road trip:** ~4,500 kg CO₂ (gas car)  
🚆 **High-speed train:** **90% less emissions** than flying  
🌍 Frequent flyers exceed **5,000 kg** CO₂ per year
""")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Highlighted Impact Statement
            Text("Every choice matters. Let’s make travel more mindful.")
                .font(.body)
                .foregroundColor(.white)
                .bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .cornerRadius(8)
            
            // Horizontally Stacked Goal-Setting Prompt & Input Field
            HStack(spacing: 6) {
                Text("Set a goal for your max carbon allowance (kg):")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.leading, 7)
                
                TextField("", text: $tempCarbonGoal)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .frame(width: 140)
                    .accentColor(.black)
                    .background(Color(white: 0.15))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .customPlaceholder(when: tempCarbonGoal.isEmpty) {
                        Text("e.g., 5000")
                            .foregroundColor(Color.gray)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Call-to-Action Button
            Button(action: {
                if let newGoal = Double(tempCarbonGoal) {
                    userCarbonGoal = newGoal
                }
                isPresented = false
            }) {
                Text("Start Your Journey")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black.opacity(1))
        .cornerRadius(16)
        .padding(.horizontal, 30)
        .shadow(radius: 10)
    }
}

// MARK: - Additional Views (Unchanged)

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
