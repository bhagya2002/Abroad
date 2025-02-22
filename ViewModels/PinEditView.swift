//
//  PinEditView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI
import PhotosUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct PinEditView: View {
    @Binding var pin: Pin
    @Binding var isPresented: Bool
    var deletePin: () -> Void
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var selectedTab: Int = 0
    @ObservedObject var viewModel: PinsViewModel
    
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showingFullScreenImage: IdentifiableImage?

    var body: some View {
        NavigationStack {
            Form {
                TitleInputView(pin: $pin)
                
                CategoryPickerView(selectedCategory: $pin.category)

                if pin.category != .none {
                    if pin.category == .visited {
                        Picker("Select Tab", selection: $selectedTab) {
                            Text("Trip Details").tag(0)
                            Text("Measure Footprint").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        if selectedTab == 0 {
                            TripDetailsView(pin: $pin, startDate: $startDate, endDate: $endDate)
                        } else {
                            MeasureFootprintView(pin: $pin)
                        }
                    }

                    if pin.category == .future {
                        FutureTripView(pin: $pin, startDate: $startDate)
                    }
                }

                if !pin.title.isEmpty {
                    DeleteButtonView(isPresented: $isPresented, deletePin: deletePin, viewModel: viewModel)
                }
            }
            // Hide the default form background and set a dark appearance.
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .foregroundColor(.white)
            .formStyle(.grouped)
            .navigationTitle(pin.title.isEmpty ? "New Pin" : "Edit Pin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(viewModel.pins.contains(where: { $0.id == pin.id }) ? "Cancel" : "Delete") {
                        if !viewModel.pins.contains(where: { $0.id == pin.id }) || pin.title.isEmpty {
                            deletePin()
                        }
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    SaveButtonView(isPresented: $isPresented, pin: $pin, viewModel: viewModel)
                }
            }
        }
        .preferredColorScheme(.dark)  // Force dark mode throughout this view.
        .task {
            await loadSavedImages()
        }
        .fullScreenCover(item: $showingFullScreenImage) { identifiableImage in
            ImageViewer(image: identifiableImage.image)
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            if let pinStart = pin.startDate { startDate = pinStart }
            if let pinEnd = pin.endDate { endDate = pinEnd }
            Task {
                await loadSavedImages()
            }
        }
        .onDisappear {
            if pin.title.isEmpty &&
                (pin.startDate == nil || pin.startDate == Date()) &&
                (pin.endDate == nil || pin.endDate == Date()) &&
                pin.placesVisited.isEmpty {
                deletePin()
            }
        }
    }

    private func loadSelectedImages() async {
        guard pin.imageFilenames.count < 10 else { return }
        for item in photoPickerItems {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                let imageName = "\(UUID().uuidString).jpg"
                if await ImageStorage.shared.saveImage(image, withName: imageName) {
                    pin.imageFilenames.append(imageName)
                }
            }
        }
        await loadSavedImages()
    }

    private func loadSavedImages() async {
        var loadedImages: [UIImage] = []
        for filename in pin.imageFilenames {
            if let image = await ImageStorage.shared.loadImage(named: filename) {
                loadedImages.append(image)
            }
        }
        selectedImages = loadedImages
    }

    private func deleteImage(at index: Int) async {
        let filename = pin.imageFilenames[index]
        await ImageStorage.shared.deleteImage(named: filename)
        pin.imageFilenames.remove(at: index)
        await loadSavedImages()
    }
}

extension PinsViewModel {
    func filteredPins(searchText: String) -> [Pin] {
        guard !searchText.isEmpty else { return [] }

        return pins.filter { pin in
            let lowercaseText = searchText.lowercased()

            if pin.title.lowercased().contains(lowercaseText) {
                return true
            }

            if lowercaseText.starts(with: "rating ="),
               let ratingValue = Int(lowercaseText.replacingOccurrences(of: "rating =", with: "").trimmingCharacters(in: .whitespaces)),
               pin.tripRating == ratingValue {
                return true
            }

            if pin.category.rawValue.lowercased().contains(lowercaseText) {
                return true
            }

            if let startDate = pin.startDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                if formatter.string(from: startDate).localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }

            if lowercaseText.starts(with: "emissions <"),
               let emissionsValue = Double(lowercaseText.replacingOccurrences(of: "emissions <", with: "").trimmingCharacters(in: .whitespaces)),
               (pin.tripBudget ?? 0) < emissionsValue {
                return true
            }

            return false
        }
    }
}
