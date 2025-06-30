//
//  MyGalleryViewModel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
//

import Foundation

class MyGalleryViewModel {
    
    private let videoRecordManager = VideoRecordManager()
    
    private(set) var allVideos: [VideoModel] = []
    private(set) var filteredVideos: [VideoModel] = []
    
    func loadVideos() {
        allVideos = videoRecordManager.fetch()
        filteredVideos = allVideos
    }
    
    func search(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            filteredVideos = allVideos
            return
        }
        filteredVideos = allVideos.filter { $0.title.lowercased().contains(trimmed) }
    }
    
    func deleteVideo(at index: Int) {
        let id = filteredVideos[index].id
        if videoRecordManager.delete(id: id) {
            loadVideos() // reload allVideos and filteredVideos
        }
    }
    
    func video(at index: Int) -> VideoModel {
        return filteredVideos[index]
    }
    
    func numberOfVideos() -> Int {
        return filteredVideos.count
    }
}
