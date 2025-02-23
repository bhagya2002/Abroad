//
//  HowToUseAppModalView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-22.
//

import SwiftUI

struct HowToUseAppModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background; tap to dismiss
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header with title and close button
                HStack {
                    Text("How to Use the App")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal)
                
                // Instructions with main steps and substeps
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("1. Drop a Pin on the Map")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Tap anywhere on the map to add a new location.")
                                Text("• Use zoom and scroll gestures for precise placement.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("2. Set Your Travel Status")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Choose between 'Visited' and 'Future Trip' categories.")
                                Text("• The selected category customizes the pin’s color and details.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("3. Attach Photos to Your Pin")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Select images from your photo gallery.")
                                Text("• Create a visual diary for each travel spot.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("4. Record Carbon Footprint Details")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Enter travel distance and choose your mode of transport.")
                                Text("• The app calculates estimated CO₂ emissions based on your input.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("5. Explore Eco-Friendly Insights")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Access sustainability tips via the hamburger menu.")
                                Text("• Get recommendations for greener travel alternatives.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("6. Track Your Progress")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Monitor your carbon savings with the progress bar.")
                                Text("• View your overall impact in reducing emissions.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("7. Manage Your Pins")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Edit or delete pins as your travel plans evolve.")
                                Text("• Update travel dates, photos, and carbon details anytime.")
                            }
                            .padding(.leading, 16)
                        }
                        
                        Group {
                            Text("8. Enjoy Offline Functionality")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• All your data is stored locally on your device.")
                                Text("• Continue exploring and logging travels without internet connectivity.")
                            }
                            .padding(.leading, 16)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85,
                   maxHeight: UIScreen.main.bounds.height * 0.65)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .preferredColorScheme(.dark)
    }
}

struct HowToUseAppModalView_Previews: PreviewProvider {
    static var previews: some View {
        HowToUseAppModalView(isPresented: .constant(true))
    }
}
