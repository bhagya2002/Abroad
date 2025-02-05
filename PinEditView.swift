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
    @State private var titleError: String? = nil
    @State private var dateError: String? = nil

    @ObservedObject var viewModel: PinsViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Location Name")
                            .font(.headline)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            TextField("Enter place name", text: $pin.title)
                                .padding(.vertical, 8)
                                .onChange(of: pin.title) { _ in validateFields() }
                        }
                        if let titleError = titleError {
                            Text(titleError)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.leading, 25) // Align with text field
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.headline)
                        Picker("Category", selection: $pin.category) {
                            Text("Visited").tag(PinCategory.visited)
                            Text("Future Travel Plan").tag(PinCategory.future)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Trip Dates")
                            .font(.headline)
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .onChange(of: startDate) { _ in validateFields() }
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .onChange(of: endDate) { _ in validateFields() }
                        if let dateError = dateError {
                            Text(dateError)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
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
                        Text("Places Visited")
                            .font(.headline)
                            .padding(.bottom)
                        ForEach($pin.placesVisited.indices, id: \ .self) { index in
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.blue)
                                TextField("Enter place name", text: $pin.placesVisited[index])
                                    .padding(.bottom, 6)
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
                    Button(action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            deletePin()
                            viewModel.savePins() // ✅ Save after deletion
                        }
                    }) {
                        Text("Delete Pin")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(pin.title.isEmpty ? "New Pin" : "Edit Pin")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Pin") {
                        if validateFields() {
                            isPresented = false
                            viewModel.savePins() // ✅ Save when closing
                        }
                    }
                    .foregroundColor(.blue) // Apple aesthetic
                    .disabled(!validateFields()) // Disable if fields are invalid
                }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            print("PinEditView opened for pin: \(pin.title)")
            // ✅ Only set start & end date if they exist in the pin
            if let pinStart = pin.startDate {
                startDate = pinStart
            }
            if let pinEnd = pin.endDate {
                endDate = pinEnd
            }
        }
    }

    private func validateFields() -> Bool {
        titleError = nil
        dateError = nil

        if pin.title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "Location name cannot be empty."
        }
        if startDate > endDate {
            dateError = "Start date cannot be after end date."
        }

        return titleError == nil && dateError == nil
    }
}
