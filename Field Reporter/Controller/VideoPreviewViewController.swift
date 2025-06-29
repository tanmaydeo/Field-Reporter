//
//  VideoPreviewViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 28/06/25.
//

import UIKit
import AVFoundation

class VideoPreviewViewController: UIViewController {
    // MARK: - UI Components
    private let dismissButton = UIButton(type: .system)
    private let videoContainerView = UIView()
    private let saveAsButton = RedCustomButton()
    private let thumbnailImageView = UIImageView()
    private let playButton = UIButton(type: .custom)
    
    // MARK: - Properties
    private let videoURL: URL
    private let playerManager = VideoPlayerManager()
    
    // MARK: - Init
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutPlayerLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPlayerLayer()
    }
}

// MARK: - Setup
private extension VideoPreviewViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubview(videoContainerView)
        videoContainerView.addSubview(thumbnailImageView)
        videoContainerView.addSubview(dismissButton)
        videoContainerView.addSubview(playButton)
        view.addSubview(saveAsButton)
    }
    
    func setupStyles() {
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        dismissButton.tintColor = .label
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        
        // Video Container
        videoContainerView.backgroundColor = .black
        videoContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoTap)))
        
        // Save Button
        saveAsButton.setTitle("Save as", for: .normal)
        saveAsButton.addTarget(self, action: #selector(didTapSaveAsButton), for: .touchUpInside)
        
        // Thumbnail
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        // Play Button
        playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        playButton.imageView?.contentMode = .scaleAspectFill
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
    }
    
    func setupConstraints() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        saveAsButton.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: saveAsButton.topAnchor, constant: -16),
            
            dismissButton.topAnchor.constraint(equalTo: videoContainerView.topAnchor, constant: 12),
            dismissButton.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveAsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveAsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveAsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            saveAsButton.heightAnchor.constraint(equalToConstant: 40),
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: videoContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoContainerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 64),
            playButton.heightAnchor.constraint(equalToConstant: 64),
        ])
    }
    
    func setupPlayer() {
        playerManager.prepare(with: videoURL)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVideoEnded),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerManager.player?.currentItem
        )
        
        playerManager.generateThumbnail(for: videoURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImageView.image = image
            }
        }
    }
    
    func layoutPlayerLayer() {
        guard let layer = playerManager.playerLayer else { return }
        layer.frame = videoContainerView.bounds
        if layer.superlayer == nil {
            videoContainerView.layer.insertSublayer(layer, below: thumbnailImageView.layer)
        }
    }
}

// MARK: - Actions
private extension VideoPreviewViewController {
    
    @objc func didTapDismiss() {
        playerManager.stop()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSaveAsButton() {
        // Placeholder for save action
    }
    
    @objc func didTapPlayButton() {
        UIView.animate(withDuration: 0.25) {
            self.thumbnailImageView.alpha = 0
        }
        
        playButton.isHidden = true
        playerManager.togglePlayPause()
    }
    
    @objc func handleVideoTap() {
        if playerManager.isPlaying {
            playButton.isHidden = false
            playerManager.togglePlayPause()
        }
    }
    
    @objc private func handleVideoEnded() {
        playerManager.player?.seek(to: .zero)
        playerManager.isPlaying = false
        
        DispatchQueue.main.async {
            self.playButton.isHidden = false
            self.thumbnailImageView.alpha = 1.0
        }
    }
}
