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
    
    var body: some View {
        Button("Save Pin") {
            isPresented = false
            viewModel.savePins()
        }
        .foregroundColor(.blue)
    }
}
