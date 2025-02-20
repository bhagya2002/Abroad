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
    @State private var entryDate: Date = Date()
    @State private var savedEntries: [JournalEntry] = []
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { closeJournal() }

            Rectangle()
                .fill(Material.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Travel Journal")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()

                    Button(action: { closeJournal() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)

                Spacer()

                ScrollView {
                    VStack(spacing: 15) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Date")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                DatePicker("", selection: $entryDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .accentColor(.black)
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.bottom, 10)

                            Text("Journal Title")
                                .font(.headline)
                                .foregroundColor(.black)

                            TextField("Enter title...", text: $journalTitle)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.black)
                                .cornerRadius(10)

                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.black)

                            TextField("Enter description...", text: $journalEntry)
                                .padding()
                                .frame(minHeight: 100)
                                .background(Color(.systemGray5))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        if !savedEntries.isEmpty {
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("📜 Previous Entries")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)

                                ScrollView {
                                    ForEach(savedEntries) { entry in
                                        Button(action: { loadEntry(entry) }) {
                                            VStack(alignment: .leading) {
                                                Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                Text(formatDate(entry.date))
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.black.opacity(0.9))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    saveJournalEntry()
                    closeJournal()
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
                .padding(.bottom, 15)
            }
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.65)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .shadow(radius: 10)
            .transition(.opacity)
            .onAppear { loadJournalEntries() }
        }
    }

    private func saveJournalEntry() {
        let newEntry = JournalEntry(title: journalTitle, entry: journalEntry, date: entryDate)
        savedEntries.append(newEntry)
        saveJournalEntries()
    }

    private func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            savedEntries = decoded
        }
    }

    private func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(savedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }

    private func loadEntry(_ entry: JournalEntry) {
        journalTitle = entry.title
        journalEntry = entry.entry
        entryDate = entry.date
    }

    private func closeJournal() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var entry: String
    var date: Date
}

#Preview {
    JournalModalView(isPresented: .constant(true))
}
