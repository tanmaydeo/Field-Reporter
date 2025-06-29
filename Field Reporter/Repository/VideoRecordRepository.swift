//
//  VideoRepository.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import Foundation

protocol VideoRepositoryProtocol {
    func create(videoModel : VideoModel)
    func getAll() -> [VideoModel]
}

struct VideoRecordRepository : VideoRepositoryProtocol {
    
    func create(videoModel: VideoModel) {
        let cdVideoRecord = CDVideoRecord(context: PersistentStorage.shared.context)
        cdVideoRecord.id = videoModel.id
        cdVideoRecord.videoTitle = videoModel.title
        cdVideoRecord.videoDescription = videoModel.description
        cdVideoRecord.videoDate = videoModel.date
        cdVideoRecord.videoPath = cdVideoRecord.videoPath
        PersistentStorage.shared.saveContext()
    }
    
    func getAll() -> [VideoModel] {
        var videoRecordArray : [VideoModel] = []
        
        do {
            let cdVideoRecord = try PersistentStorage.shared.context.fetch(CDVideoRecord.fetchRequest())
            cdVideoRecord.forEach({ videoRecord in
                let videoRecord = VideoModel(id: videoRecord.id ?? UUID(), title: videoRecord.videoTitle ?? "NA", description: videoRecord.videoDescription ?? "NA", path: videoRecord.videoPath ?? "NA", date: videoRecord.videoDate ?? Date.now)
                videoRecordArray.append(videoRecord)
            })
        }
        catch let error {
            print(error)
        }
        return videoRecordArray
    }
    
}
