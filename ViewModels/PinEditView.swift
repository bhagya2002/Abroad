//
//  PinEditView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI
import PhotosUI

// ✅ Identifiable Wrapper for UIImage
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
    @State private var showingFullScreenImage: IdentifiableImage? // ✅ Fixed type

    var body: some View {
        NavigationStack {
            Form {
                TitleInputView(pin: $pin)
//                Section(header: Text("📍 Choose a Pin Icon")) {
//                    Picker("Select Icon", selection: $pin.icon) {
//                        ForEach(["📍", "🏔", "🏖", "🏙", "🎢", "🌲", "🗽", "star", "mappin"], id: \.self) { icon in
//                            Text(icon).tag(icon)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                }

                CategoryPickerView(selectedCategory: $pin.category)

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
                
                // Photo Upload Section
                // ✅ Photo Upload Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Photos")
                        .font(.headline)

                    // ✅ Photo Gallery (Apple-Like Horizontal Scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedImages.enumerated()), id: \.element) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .shadow(radius: 1)
                                        .onTapGesture {
                                            showingFullScreenImage = IdentifiableImage(image: image) // ✅ Tap to fullscreen
                                        }

                                    // ✅ Apple-Like Delete Button (Subtle, Inline)
                                    Button(action: {
                                        Task { await deleteImage(at: index) }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 5, y: -5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ✅ Apple-Like Photos Picker (No Highlighting)
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10 - pin.imageFilenames.count, matching: .images) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Select Photos")
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground))) // ✅ No Highlighting Effect
                    }
                    .padding(.horizontal)
                    .onChange(of: photoPickerItems) { _ in
                        Task { await loadSelectedImages() }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))


                DeleteButtonView(isPresented: $isPresented, deletePin: deletePin, viewModel: viewModel)
            }
            .formStyle(.grouped)
            .navigationTitle(pin.title.isEmpty ? "New Pin" : "Edit Pin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if pin.title.isEmpty {
                        Button("Cancel") {
                            deletePin()
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    } else {
                        Button("Delete") {
                            deletePin()
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    SaveButtonView(isPresented: $isPresented, pin: $pin, viewModel: viewModel)
                }
            }
        }
        .task {
            await loadSavedImages()
        }
        .fullScreenCover(item: $showingFullScreenImage) { identifiableImage in
            ImageViewer(image: identifiableImage.image) // ✅ Fix applied
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
            if pin.title.isEmpty && (pin.startDate == nil || pin.startDate == Date()) && (pin.endDate == nil || pin.endDate == Date()) && pin.placesVisited.isEmpty {
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

// ✅ Full-Screen Image Viewer
struct ImageViewer: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                dismiss() // ✅ Tap anywhere to dismiss
            }
        }
    }
}

extension PinsViewModel {
    func filteredPins(searchText: String) -> [Pin] {
        guard !searchText.isEmpty else { return [] }

        return pins.filter { pin in
            let lowercaseText = searchText.lowercased()

            // ✅ Match by Title
            if pin.title.lowercased().contains(lowercaseText) {
                return true
            }

            // ✅ Match by Rating (e.g., "Rating = 4")
            if lowercaseText.starts(with: "rating ="),
               let ratingValue = Int(lowercaseText.replacingOccurrences(of: "rating =", with: "").trimmingCharacters(in: .whitespaces)),
               pin.tripRating == ratingValue {
                return true
            }

            // ✅ Match by Category
            if pin.category.rawValue.lowercased().contains(lowercaseText) {
                return true
            }

            // ✅ Match by Date (Formatted Search)
            if let startDate = pin.startDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                if formatter.string(from: startDate).localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }

            // ✅ Match by Emissions (e.g., "Emissions < 100")
            if lowercaseText.starts(with: "emissions <"),
               let emissionsValue = Double(lowercaseText.replacingOccurrences(of: "emissions <", with: "").trimmingCharacters(in: .whitespaces)),
               (pin.tripBudget ?? 0) < emissionsValue {
                return true
            }

            return false
        }
    }
}

