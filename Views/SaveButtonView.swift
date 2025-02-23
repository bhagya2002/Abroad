//
//  SaveButtonView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

// Save Button Component
struct SaveButtonView: View {
    @Binding var isPresented: Bool
    @Binding var pin: Pin
    @ObservedObject var viewModel: PinsViewModel
    @State private var showValidationAlert = false
    
    var body: some View {
        Button("Save Pin") {
            // Validate that a title is entered (not just spaces)
            if pin.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showValidationAlert = true
            } else {
                viewModel.savePins()
                isPresented = false
            }
        }
        .foregroundColor(.blue)
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a name for the pin before saving.")
        }
    }
}
