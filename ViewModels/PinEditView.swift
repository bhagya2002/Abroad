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
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var selectedTab: Int = 0
    @ObservedObject var viewModel: PinsViewModel

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

                DeleteButtonView(isPresented: $isPresented, deletePin: deletePin, viewModel: viewModel)
            }
            .formStyle(.grouped)
            .navigationTitle(pin.title.isEmpty ? "New Pin" : "Edit Pin")
            .toolbar {
                // ✅ Conditional Cancel or Delete Button on Top Left
                ToolbarItem(placement: .cancellationAction) {
                    if pin.title.isEmpty { // If it's a new pin
                        Button("Cancel") {
                            deletePin() // Remove pin from list
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    } else { // If editing an existing pin
                        Button("Delete") {
                            deletePin() // Call delete function
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // ✅ Save Button on Top Right (Inside ButtonView)
                ToolbarItem(placement: .confirmationAction) {
                    SaveButtonView(isPresented: $isPresented, pin: $pin, viewModel: viewModel)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            if let pinStart = pin.startDate { startDate = pinStart }
            if let pinEnd = pin.endDate { endDate = pinEnd }
        }
        .onDisappear {
            if pin.title.isEmpty && (pin.startDate == nil || pin.startDate == Date()) && (pin.endDate == nil || pin.endDate == Date()) && pin.placesVisited.isEmpty {
                deletePin() // Automatically delete empty pins
            }
        }
    }
}
