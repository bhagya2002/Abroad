//
//  TitleInputView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

// Title Input Component
struct TitleInputView: View {
    @Binding var pin: Pin
    @State private var titleError: String? = nil
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 5) {
                Text("Location Name").font(.headline)
                HStack {
                    Image(systemName: "mappin.and.ellipse").foregroundColor(.blue)
                    TextField("Enter place name", text: $pin.title)
                        .padding(.vertical, 8)
                        .onChange(of: pin.title) { _ in validateTitle() }
                }
                if let titleError = titleError {
                    Text(titleError).font(.footnote).foregroundColor(.red).padding(.leading, 25)
                }
            }
        }
    }

    private func validateTitle() {
        titleError = pin.title.trimmingCharacters(in: .whitespaces).isEmpty ? "Location name cannot be empty." : nil
    }
}
