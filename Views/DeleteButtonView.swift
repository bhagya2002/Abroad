//
//  DeleteButtonView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-05.
//

import SwiftUI

struct DeleteButtonView: View {
    @Binding var isPresented: Bool
    var deletePin: () -> Void
    @ObservedObject var viewModel: PinsViewModel
    
    var body: some View {
        Section {
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    deletePin()
                    viewModel.savePins()
                }
            }) {
                Text("Delete Pin").foregroundColor(.red).frame(maxWidth: .infinity)
            }
        }
    }
}
