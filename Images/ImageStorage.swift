//
//  ImageStorage.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-09.
//


import UIKit

actor ImageStorage {
    static let shared = ImageStorage()
    
    func saveImage(_ image: UIImage, withName name: String) async -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        let url = getFileURL(for: name)
        do {
            try data.write(to: url)
            return true
        } catch {
            print("❌ Failed to save image:", error)
            return false
        }
    }
    
    func loadImage(named name: String) async -> UIImage? {
        let url = getFileURL(for: name)
        return UIImage(contentsOfFile: url.path)
    }
    
    func deleteImage(named name: String) async {
        let url = getFileURL(for: name)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func getFileURL(for name: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(name)
    }
}
