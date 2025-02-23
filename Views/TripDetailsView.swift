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
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Dates").font(.headline)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { _ in validateDates() }
                        .accentColor(.black)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { _ in validateDates() }
                        .accentColor(.black)
                    if let dateError = dateError {
                        Text(dateError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemBackground)))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Rating").font(.headline)
                    Slider(
                        value: Binding(
                            get: { Double(pin.tripRating ?? 0) },
                            set: { pin.tripRating = Int($0) }
                        ),
                        in: 0...5,
                        step: 1
                    )
                    .padding(.horizontal)
                    .accentColor(.gray)
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Cost").font(.headline)
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("Enter cost ($)", text: $budgetText)
                            .accentColor(.gray)
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Photos")
                        .font(.headline)

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
                                            showingFullScreenImage = IdentifiableImage(image: image)
                                        }

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

                    PhotosPicker(
                        selection: $photoPickerItems,
                        maxSelectionCount: 10 - pin.imageFilenames.count,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Select Photos")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
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
            startDate = pin.startDate ?? Date()
            endDate = pin.endDate ?? Date()
            if let budget = pin.tripBudget {
                budgetText = String(format: "%.2f", budget)
            }
            Task {
                await loadSavedImages()
            }
        }
        .onDisappear {
            pin.startDate = startDate
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
            return String(filtered.dropLast())
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
                    dismiss()
                }
        }
    }
}
