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
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            VStack(spacing: 0) {
                HStack {
                    Text("How to Use the App")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("1. Drop a Pin on the Map")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Tap anywhere on the map to add a new location.")
                                Text("• Use zoom and scroll gestures to move around the map.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("2. Set Your Travel Status")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Choose between 'Visited' and 'Future Trip' categories.")
                                Text("• The selected category customizes the pin’s color and details.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("3. Attach Photos to Your Pin")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Select images from your photo gallery.")
                                Text("• Create a visual diary for each travel spot.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("4. Record Carbon Footprint Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Enter travel distance and choose your mode of transport.")
                                Text("• The app calculates estimated CO₂ emissions based on your input.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("5. Explore New Destinations")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Get an eco-friendly packing list for the region.")
                                Text("• Explore sustainable travel options for various regions.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("6. Track Your Progress")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Monitor your carbon savings with the progress bar.")
                                Text("• View your overall impact in reducing emissions.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("7. Manage Your Pins")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Edit or delete pins as your travel plans evolve.")
                                Text("• Update travel dates, photos, and carbon details anytime.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Group {
                            Text("8. Write Down Your Thoughts")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Write a journal entry for any day.")
                                Text("• Go back to previous journal entries.")
                            }
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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
