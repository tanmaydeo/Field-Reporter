//
//  VideoPlayerManager.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import UIKit
import AVFoundation

class VideoPlayerManager {
    
    private(set) var player: AVPlayer?
    private(set) var playerLayer: AVPlayerLayer?
    private(set) var isPlaying: Bool = false
    
    func prepare(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, _ in
            if let cgImage = image {
                completion(UIImage(cgImage: cgImage))
            } else {
                completion(nil)
            }
        }
    }
}
