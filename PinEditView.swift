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
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text("Location Name")
                            .font(.headline)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            TextField("Enter place name", text: $pin.title)
                                .padding(.vertical, 8)
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.headline)
                            .padding(.bottom)
                        Picker("Category", selection: $pin.category) {
                            Text("Visited").tag(PinCategory.visited)
                            Text("Future Travel Plan").tag(PinCategory.future)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Trip Dates")
                            .font(.headline)
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .onChange(of: startDate) { newStart in
                                pin.startDate = newStart
                            }
                            .onChange(of: endDate) { newEnd in
                                pin.endDate = newEnd
                            }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Places Visited")
                            .font(.headline)
                            .padding(.bottom)
                        ForEach($pin.placesVisited.indices, id: \ .self) { index in
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.blue)
                                TextField("Enter place name", text: $pin.placesVisited[index])
                            }
                        }
                        .onDelete { indexSet in
                            pin.placesVisited.remove(atOffsets: indexSet)
                        }
                        Button(action: {
                            pin.placesVisited.append("")
                        }) {
                            Label("Add Place", systemImage: "plus")
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Trip Rating")
                            .font(.headline)
                        Slider(
                            value: Binding(
                                get: { Double(pin.tripRating ?? 0) },
                                set: { pin.tripRating = Int($0) }
                            ),
                            in: 0...5,
                            step: 1
                        )
                        .padding(.horizontal)
                        HStack {
                            ForEach(0...5, id: \ .self) { rating in
                                Text(rating == 0 ? "No Rating" : "\(rating)")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Attach Photos")
                            .font(.headline)
                            .padding(.bottom)
                        PhotosPicker("Select Images", selection: $imagePickerItems, matching: .images)
                            .onChange(of: imagePickerItems) { newItems in
                                loadSelectedImages(newItems)
                            }
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImages, id: \ .self) { image in
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
                }
                
                Section {
                    Button(action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            deletePin()
                        }
                    }) {
                        Text("Delete Pin")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Pin Information")
            .padding(.bottom)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            print("PinEditView opened for pin: \(pin.title)")
            if let pinStart = pin.startDate, let pinEnd = pin.endDate {
                startDate = pinStart
                endDate = pinEnd
            }
        }
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
            pin.photos = newImages.compactMap { $0.pngData() }
        }
    }
}
