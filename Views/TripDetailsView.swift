//
//  TripDetailsView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI
import PhotosUI

struct TripDetailsView: View {
    @Binding var pin: Pin
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var dateError: String? = nil
    @State private var budgetText: String = ""
    
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showingFullScreenImage: IdentifiableImage?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing for better separation
                
                // Trip Dates Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Dates").font(.headline)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { _ in validateDates() }
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { _ in validateDates() }
                    if let dateError = dateError {
                        Text(dateError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))

                // Trip Rating Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Rating").font(.headline)
                    Slider(value: Binding(get: { Double(pin.tripRating ?? 0) }, set: { pin.tripRating = Int($0) }), in: 0...5, step: 1)
                        .padding(.horizontal)
                    HStack {
                        ForEach(0...5, id: \.self) { rating in
                            Text(rating == 0 ? "No Rating" : "\(rating)")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))

                // Trip Budget Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Cost").font(.headline)
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("Enter cost ($)", text: $budgetText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: budgetText) { newValue in
                                budgetText = filterNumbersOnly(newValue)
                                if let budgetValue = Double(budgetText) {
                                    pin.tripBudget = budgetValue
                                }
                            }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
                
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
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground))) // ✅ No Highlighting Effect
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    .onChange(of: photoPickerItems) { _ in
                        Task { await loadSelectedImages() }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))
            }
            .padding()
        }
        .onAppear {
            // ✅ Only set start & end dates if they are nil, otherwise keep previous values
            startDate = pin.startDate ?? Date() // Use existing date if available
            endDate = pin.endDate ?? Date()

            if let budget = pin.tripBudget {
                budgetText = String(format: "%.2f", budget)
            }
        }
        .onDisappear {
            pin.startDate = startDate // Save selected date to pin
            pin.endDate = endDate
        }
    }

    private func validateDates() {
        dateError = startDate > endDate ? "❌ Start date cannot be after end date." : nil
    }

    /// Filters input to allow only numbers and one decimal point
    private func filterNumbersOnly(_ input: String) -> String {
        let filtered = input.filter { "0123456789.".contains($0) }
        let decimalCount = filtered.filter { $0 == "." }.count
        if decimalCount > 1 {
            return String(filtered.dropLast()) // Prevent multiple decimal points
        }
        return filtered
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
