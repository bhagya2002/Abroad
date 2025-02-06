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
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
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
                // ✅ Cancel Button on Top Left
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
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
    }
}
