import SwiftUI
import MapKit

class PinsViewModel: ObservableObject {
    @Published var pins: [Pin] = []
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @StateObject private var viewModel = PinsViewModel()
    @State private var selectedPin: Pin? = nil
    @State private var isEditingPin: Bool = false
    @State private var isSidebarOpen: Bool = false // Track sidebar visibility

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        isSidebarOpen = true
                    }) {
                        Image(systemName: "sidebar.leading")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .foregroundColor(.primary)
                    }
                    .background(Color(.systemBackground))

                    EcoTipBannerView()
                        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                        .multilineTextAlignment(.center)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .background(Color(.systemBackground))
                
                ZStack {
                    MapView(region: $region, pins: $viewModel.pins, selectedPin: $selectedPin, isEditingPin: $isEditingPin)
                        .edgesIgnoringSafeArea(.all)
                }
                .frame(height: UIScreen.main.bounds.height * 0.9)
                .padding(15)
                .cornerRadius(10)
            }
            .sheet(isPresented: $isEditingPin, onDismiss: {
                selectedPin = nil
            }) {
                if let index = selectedPinIndex(), index < viewModel.pins.count {
                    PinEditView(
                        pin: $viewModel.pins[index],
                        isPresented: $isEditingPin,
                        deletePin: {
                            isEditingPin = false
                            selectedPin = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if index < viewModel.pins.count {
                                    viewModel.pins.remove(at: index)
                                }
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                } else {
                    Text("⚠️ No pin selected")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }

        private func selectedPinIndex() -> Int? {
            guard let selectedPin = selectedPin else { return nil }
            
            let index = viewModel.pins.firstIndex(where: { $0.id == selectedPin.id })
            
            print("🔍 selectedPinIndex() -> \(index.map(String.init) ?? "nil") for selectedPin: \(selectedPin.title)")
            
            return index
        }
    }

    #Preview {
        ContentView()
    }
