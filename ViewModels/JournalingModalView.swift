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
            // ✅ Background Blur Effect (Matches Spotlight Search)
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    closeJournal()
                }

            Rectangle()
                .fill(Material.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ✅ Header with Dark Background
                HStack {
                    Text("📖 Travel Journal")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        closeJournal()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20) // ✅ Smaller X button
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.9))

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 10)

                ScrollView {
                    VStack(spacing: 15) {
                        // ✅ Compact Date Selector (Inline)
                        HStack {
                            Text("📅 Date:")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker("", selection: $entryDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(CompactDatePickerStyle()) // ✅ Compact Picker
                        }
                        .padding()
                        .background(Color.black.opacity(0.9)) // ✅ Dark Gray Background
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)

                        // ✅ Title Input (Matches Spotlight Style)
                        TextField("Journal Title", text: $journalTitle)
                            .padding()
                            .background(Color.black.opacity(0.9)) // ✅ Dark Gray Background
                            .foregroundColor(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)

                        // ✅ Journal Text Entry (Matches Spotlight Style)
                        TextEditor(text: $journalEntry)
                            .frame(minHeight: 250, maxHeight: 350)
                            .padding()
                            .background(Color.black.opacity(0.9)) // ✅ Dark Gray Background
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .padding(.horizontal)

                        Spacer()

                        // ✅ Saved Journal Entries List
                        if !savedEntries.isEmpty {
                            VStack(alignment: .leading) {
                                Text("📜 Previous Entries")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)

                                ScrollView {
                                    ForEach(savedEntries) { entry in
                                        Button(action: {
                                            loadEntry(entry)
                                        }) {
                                            HStack {
                                                Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(formatDate(entry.date))
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color.black.opacity(0.9)) // ✅ Dark Gray Background
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

                // ✅ Save Button
                Button(action: {
                    saveJournalEntry()
                    closeJournal()
                }) {
                    Text("💾 Save Entry")
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
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.85)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
            .transition(.move(edge: .bottom)) // ✅ Close animation
            .onAppear {
                loadJournalEntries()
            }
        }
    }

    // ✅ Save Journal Entry
    private func saveJournalEntry() {
        let newEntry = JournalEntry(title: journalTitle, entry: journalEntry, date: entryDate)
        savedEntries.append(newEntry)
        saveJournalEntries()
    }

    // ✅ Load Journal Entries
    private func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            savedEntries = decoded
        }
    }

    // ✅ Save All Journal Entries
    private func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(savedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }

    // ✅ Load Selected Entry
    private func loadEntry(_ entry: JournalEntry) {
        journalTitle = entry.title
        journalEntry = entry.entry
        entryDate = entry.date
    }

    // ✅ Close Journal with Animation
    private func closeJournal() {
        withAnimation {
            isPresented = false
        }
    }

    // ✅ Format Date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// ✅ Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var entry: String
    var date: Date
}

#Preview {
    JournalModalView(isPresented: .constant(true))
}
