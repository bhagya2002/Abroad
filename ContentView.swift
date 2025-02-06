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
        span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 60.0) // Wider view for entire continent
    )

    @StateObject private var viewModel = PinsViewModel()
    @State private var selectedPin: Pin? = nil
    @State private var isEditingPin: Bool = false
    @State private var isSidebarOpen: Bool = false // Track sidebar visibility

    var body: some View {
        HStack {
            // ✅ Sidebar that expands when clicked
            if isSidebarOpen {
                sidebarView()
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    .background(Color(.systemGray6))
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: isSidebarOpen)
            }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            isSidebarOpen.toggle()
                        }
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
                                if !viewModel.pins[index].title.trimmingCharacters(in: .whitespaces).isEmpty {
                                    isEditingPin = false
                                    viewModel.savePins() // ✅ Save pins when closing
                                }
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
                                    viewModel.savePins() // ✅ Save pins after deletion
                                }
                            },
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
        let index = viewModel.pins.firstIndex(where: { $0.id == selectedPin.id })
        return index
    }

    // ✅ Sidebar view that shows visited & planned trips
    private func sidebarView() -> some View {
        VStack(alignment: .leading) {
            Text("📍 My Travel Logs")
                .font(.largeTitle)
                .bold()
                .padding()
                .padding(.top, 15)

            List {
                // ✅ Section for Visited Places
                Section(header: Text("Visited Locations").font(.headline)) {
                    ForEach(viewModel.pins.filter { $0.category == .visited }, id: \.id) { pin in
                        VStack(alignment: .leading) {
                            Text(pin.title)
                                .font(.headline)
                                .padding(.bottom, 4)
                            if let start = pin.startDate, let end = pin.endDate {
                                Text("🗓️ \(formattedDate(start)) - \(formattedDate(end))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 4)
                            }
                            if let rating = pin.tripRating {
                                Text("⭐ Rating: \(rating)/5")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(.bottom, 4)
                            }
                            if let budget = pin.tripBudget {
                                Text("💰 Budget: \(budget, format: .currency(code: "USD"))")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            if !pin.placesVisited.isEmpty {
                                Text("📍 Places: " + pin.placesVisited.prefix(3).joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                // ✅ Section for Future Travel Plans
                Section(header: Text("Future Travel Plans").font(.headline)) {
                    ForEach(viewModel.pins.filter { $0.category == .future }, id: \.id) { pin in
                        VStack(alignment: .leading) {
                            Text(pin.title)
                                .font(.headline)
                                .padding(.bottom, 4)
                            Text("🗓️ Planned Trip")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color(.systemBackground))

//            Spacer()

//            Button(action: {
//                withAnimation {
//                    isSidebarOpen = false
//                }
//            }) {
//                Text("Close Sidebar")
//                    .font(.headline)
//                    .foregroundColor(.blue)
//                    .padding()
//            }
//            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // ✅ Helper function to format dates
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
