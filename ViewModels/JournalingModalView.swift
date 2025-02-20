//
//  JournalingModalView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-18.
//


import SwiftUI

struct JournalModalView: View {
    @Binding var isPresented: Bool
    @State private var journalTitle: String = ""
    @State private var journalEntry: String = ""
    @State private var entryDate: String = ""

    var body: some View {
        ZStack {
            // Background Blur Effect
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Modal Content
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Travel Journal")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)

                    Spacer()

                    // Close Button
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Date Display
                Text(entryDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Title Input
                TextField("Journal Title", text: $journalTitle)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Journal Text Entry
                TextEditor(text: $journalEntry)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Spacer()

                // Save Button
                Button(action: {
                    saveJournalEntry()
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("Save Entry")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            .onAppear {
                loadJournalEntry()
                entryDate = formatDate(Date())
            }
        }
    }

    // Save Journal Entry
    private func saveJournalEntry() {
        let entryData: [String: String] = [
            "title": journalTitle,
            "entry": journalEntry,
            "date": entryDate
        ]
        UserDefaults.standard.set(entryData, forKey: "journalEntry")
    }

    // Load Journal Entry
    private func loadJournalEntry() {
        if let savedData = UserDefaults.standard.dictionary(forKey: "journalEntry") as? [String: String] {
            journalTitle = savedData["title"] ?? ""
            journalEntry = savedData["entry"] ?? ""
            entryDate = savedData["date"] ?? ""
        }
    }

    // Format Date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    JournalModalView(isPresented: .constant(true))
}
