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
                
                // ✅ NEW: Photo Upload Section
                Section(header: Text("📸 Add Photos (Max 10)")) {
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10 - pin.imageFilenames.count, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select Photos")
                        }
                    }
                    .onChange(of: photoPickerItems) { _ in
                        Task {
                            await loadSelectedImages()
                        }
                    }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(selectedImages.enumerated()), id: \.element) { index, image in
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .onTapGesture {
                                            showingFullScreenImage = IdentifiableImage(image: image) // ✅ Fix
                                        }

                                    Button(action: {
                                        Task {
                                            await deleteImage(at: index)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }

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
                    dismiss() // ✅ Correct way to dismiss in iOS 15+
                }
        }
    }
}
