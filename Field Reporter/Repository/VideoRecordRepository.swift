//
//  VideoRepository.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import Foundation
import CoreData

protocol VideoRepositoryProtocol {
    func create(videoModel : VideoModel)
    func getAll() -> [VideoModel]
    func delete(_ id : UUID) -> Bool
}

struct VideoRecordRepository : VideoRepositoryProtocol {
    
    func create(videoModel: VideoModel) {
        let cdVideoRecord = CDVideoRecord(context: PersistentStorage.shared.context)
        cdVideoRecord.id = videoModel.id
        cdVideoRecord.videoTitle = videoModel.title
        cdVideoRecord.videoDescription = videoModel.description
        cdVideoRecord.videoDate = videoModel.date
        cdVideoRecord.videoPath = videoModel.path
        cdVideoRecord.videoThumbnail = videoModel.thumbnail
        cdVideoRecord.videoTimeInterval = videoModel.time
        PersistentStorage.shared.saveContext()
    }
    
    func getAll() -> [VideoModel] {
        var videoRecordArray : [VideoModel] = []
        
        do {
            let cdVideoRecord = try PersistentStorage.shared.context.fetch(CDVideoRecord.fetchRequest())
            cdVideoRecord.forEach({ videoRecord in
                let videoRecord = VideoModel(id: videoRecord.id ?? UUID(), title: videoRecord.videoTitle ?? "NA", description: videoRecord.videoDescription ?? "NA", path: videoRecord.videoPath ?? "NA", date: videoRecord.videoDate ?? Date.now, time: videoRecord.videoTimeInterval, thumbnail: videoRecord.videoThumbnail ?? Data())
                videoRecordArray.insert(videoRecord, at: 0)
            })
        }
        catch let error {
            print(error)
        }
        return videoRecordArray
    }
    
    func delete(_ id: UUID) -> Bool {
        let cdVideoRecordByID = getCDVideoRecordByID(id)
        guard let cdVideoRecordByID else {
            return false
        }
        PersistentStorage.shared.context.delete(cdVideoRecordByID)
        PersistentStorage.shared.saveContext()
        return true
    }
    
    private func getCDVideoRecordByID(_ id : UUID) -> CDVideoRecord? {
        let fetchRequest : NSFetchRequest<CDVideoRecord> = CDVideoRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id as CVarArg)
        do {
            let record = try PersistentStorage.shared.context.fetch(fetchRequest).first
            return record
        }
        catch let error {
            print(error)
        }
        return nil
    }
    
}
