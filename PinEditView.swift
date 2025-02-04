//
//  PinEditView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI
import PhotosUI

struct PinEditView: View {
    @Binding var pin: Pin
    @Binding var isPresented: Bool
    var deletePin: () -> Void
    @State private var selectedImages: [UIImage] = []
    @State private var imagePickerItems: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Location Name")) {
                    TextField("Enter place name", text: $pin.title)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }

                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $pin.category) {
                        Text("Visited").tag(PinCategory.visited)
                        Text("Future Travel Plan").tag(PinCategory.future)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }

                Section(header: Text("Trip Dates")) {
                    DatePicker("Start Date", selection: Binding(get: {
                        pin.startDate ?? Date()
                    }, set: { newValue in
                        pin.startDate = newValue
                    }), displayedComponents: .date)

                    DatePicker("End Date", selection: Binding(get: {
                        pin.endDate ?? Date()
                    }, set: { newValue in
                        pin.endDate = newValue
                    }), displayedComponents: .date)
                }

                Section(header: Text("Places Visited")) {
                    ForEach($pin.placesVisited.indices, id: \.self) { index in
                        TextField("Enter place name", text: $pin.placesVisited[index])
                            .textFieldStyle(.roundedBorder)
                    }
                    .onDelete { indexSet in
                        pin.placesVisited.remove(atOffsets: indexSet)
                    }

                    Button("Add Place") {
                        pin.placesVisited.append("")
                    }
                }

                Section(header: Text("Trip Rating")) {
                    Picker("Rate Your Trip", selection: Binding(
                        get: { pin.tripRating ?? 3 }, // ✅ Default to 3 if nil
                        set: { pin.tripRating = $0 }
                    )) {
                        ForEach(1...5, id: \.self) { rating in
                            Text("\(rating) Stars").tag(rating)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Attach Photos")) {
                    PhotosPicker("Select Images", selection: $imagePickerItems, matching: .images)
                        .onChange(of: imagePickerItems) { newItems in
                            loadSelectedImages(newItems)
                        }

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }

                Section {
                    Button(action: {
                        isPresented = false // ✅ First, close the edit screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            deletePin() // ✅ Delete the pin after UI updates
                        }
                    }) {
                        Text("Delete Pin")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Pin")
        }
        .presentationDetents([.medium, .large]) // ✅ Opens at medium (half-screen) by default
        .presentationDragIndicator(.visible) // ✅ Enables drag indicator for dismissing
        .onAppear {
            print("PinEditView opened for pin: \(pin.title)")
        }
    }

    private func addNewPlace() {
        let newPlace = "New Place \(pin.placesVisited.count + 1)"
        pin.placesVisited.append(newPlace)
    }

    private func loadSelectedImages(_ newItems: [PhotosPickerItem]) {
        Task {
            var newImages: [UIImage] = []
            for item in newItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    newImages.append(image)
                }
            }
            selectedImages = newImages
            pin.photos = newImages.compactMap { $0.pngData() } // ✅ Convert images to Data for storage
        }
    }
}
