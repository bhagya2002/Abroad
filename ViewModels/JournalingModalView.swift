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
    @State private var errorMessage: String = ""

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

                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }) {
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
                                    .foregroundColor(.white)
                                    .padding(.trailing, 16)
                                    .accentColor(.black)

                                DatePicker("Date", selection: $entryDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .background(Color.white)
                                    .accentColor(.black)
                            }
                            .cornerRadius(10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)

                            Text("Journal Title")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("Enter title...", text: $journalTitle)
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.bottom, 10)
                                .accentColor(.black)

                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextEditor(text: $journalEntry)
                                .frame(minHeight: 150)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .accentColor(.black)
                        }
                        .padding()
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }

                        if !savedEntries.isEmpty {
                            Spacer()
                            VStack(alignment: .leading, spacing: 10) {
                                Text("📜 Previous Entries")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)

                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(savedEntries) { entry in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text(formatDate(entry.date))
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                Button(action: { loadEntry(entry) }) {
                                                    Image(systemName: "pencil")
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                }
                                                Button(action: { deleteEntry(entry) }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                        .padding()
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.black.opacity(0.9))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    if journalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                       journalEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please enter a title and description."
                        return
                    }
                    errorMessage = ""
                    saveJournalEntry()
                    clearFields()
                }) {
                    Text("Save")
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
            .background(Color.black.opacity(0.75))
            .cornerRadius(20)
            .shadow(radius: 10)
            .onAppear { loadJournalEntries() }
        }
    }
    
    private func deleteEntry(_ entry: JournalEntry) {
        savedEntries.removeAll { $0.id == entry.id }
        if let encoded = try? JSONEncoder().encode(savedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }

    private func saveJournalEntry() {
        if let editingEntry = selectedEntry,
           let index = savedEntries.firstIndex(where: { $0.id == editingEntry.id }) {
            savedEntries[index].title = journalTitle
            savedEntries[index].entry = journalEntry
            savedEntries[index].date = entryDate
        } else {
            let newEntry = JournalEntry(id: UUID(), title: journalTitle, entry: journalEntry, date: entryDate)
            savedEntries.append(newEntry)
        }
        
        if let encoded = try? JSONEncoder().encode(savedEntries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }

    private func clearFields() {
        journalTitle = ""
        journalEntry = ""
        entryDate = Date()
        selectedEntry = nil
    }

    private func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            savedEntries = decoded
        }
    }

    private func loadEntry(_ entry: JournalEntry) {
        journalTitle = entry.title
        journalEntry = entry.entry
        entryDate = entry.date
        selectedEntry = entry
    }

    private func closeJournal() {
        withAnimation(.easeOut(duration: 0.2)) {
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
