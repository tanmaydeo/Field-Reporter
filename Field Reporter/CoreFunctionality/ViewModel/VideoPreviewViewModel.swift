//
//  VideoPreviewViewModel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
//

import UIKit
import AVFoundation

class VideoPreviewViewModel {
    
    private let videoURL: URL
    private(set) var thumbnailImage: UIImage?
    private(set) var playerManager: VideoPlayerManager = VideoPlayerManager()
    private let videoRecordManager = VideoRecordManager()
    private let videoTime: Int
    
    init(videoURL: URL, videoTime: Int) {
        self.videoURL = videoURL
        self.videoTime = videoTime
    }
    
    func prepareVideoPlayer(completion: @escaping (UIImage?) -> Void) {
        playerManager.prepare(with: videoURL)
        
        playerManager.generateThumbnail(for: videoURL) { [weak self] image in
            self?.thumbnailImage = image
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func getPlayerLayer() -> AVPlayerLayer? {
        return playerManager.playerLayer
    }
    
    func handlePlayPause() {
        playerManager.togglePlayPause()
    }
    
    func stopPlayback() {
        playerManager.stop()
    }
    
    func isPlaying() -> Bool {
        return playerManager.isPlaying
    }
    
    func seekToStart() {
        playerManager.player?.seek(to: .zero)
        playerManager.isPlaying = false
    }
    
    func saveVideo(title: String, description: String, onComplete: @escaping () -> Void) {
        guard let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8) else {
            return
        }
        let model = VideoModel(
            id: UUID(),
            title: title,
            description: description,
            path: videoURL.absoluteString,
            date: Date(),
            time: Int32(videoTime),
            thumbnail: thumbnailData
        )
        videoRecordManager.create(videoModel: model)
        onComplete()
    }
}
