//
//  VideoManager.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import Foundation

struct VideoRecordManager {
    
    private let _videoRepository : VideoRecordRepository = VideoRecordRepository()
    
    func create(videoModel : VideoModel) {
        _videoRepository.create(videoModel: videoModel)
    }
    
    func fetch() -> [VideoModel] {
        return _videoRepository.getAll()
    }
    
    func delete(id : UUID) -> Bool {
        return _videoRepository.delete(id)
    }
}
