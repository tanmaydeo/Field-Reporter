//
//  VideoPreviewViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 28/06/25.
//

import UIKit
import AVFoundation

class VideoPreviewViewController: UIViewController {
    
    // MARK: - Properties
    
    private let videoURL: URL
    private let dismissButton = UIButton(type: .system)
    private let videoContainerView = UIView()
    private let saveAsButton = RedCustomButton()
    private let videoThumbnailImageView : UIImageView = UIImageView()
    
    private let playerManager = VideoPlayerManager()
    
    // MARK: - Lifecycle
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        preparePlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlayerLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerManager.playerLayer?.frame = videoContainerView.bounds
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubview(dismissButton)
        view.addSubview(videoContainerView)
        videoContainerView.addSubview(videoThumbnailImageView)
        view.addSubview(saveAsButton)
    }
    
    func setupStyles() {
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .label
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        
        // Video Container
        videoContainerView.backgroundColor = .black
        
        // Save As Button
        saveAsButton.setTitle("Save as", for: .normal)
        saveAsButton.addTarget(self, action: #selector(didTapSaveAsButton), for: .touchUpInside)
        
        //Thumbnail
        videoThumbnailImageView.contentMode = .scaleAspectFill
        videoThumbnailImageView.clipsToBounds = true
    }
    
    func setupConstraints() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        saveAsButton.translatesAutoresizingMaskIntoConstraints = false
        videoThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 12),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 16),
            videoContainerView.bottomAnchor.constraint(equalTo: saveAsButton.topAnchor, constant: -16),
            
            saveAsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveAsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveAsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            saveAsButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoThumbnailImageView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            videoThumbnailImageView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            videoThumbnailImageView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            videoThumbnailImageView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        ])
    }
}

private extension VideoPreviewViewController {
    
    func preparePlayer() {
        playerManager.prepare(with: videoURL)
        playerManager.generateThumbnail(for: videoURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.videoThumbnailImageView.image = image
            }
        }
    }
    
    func setupPlayerLayer() {
        guard let playerLayer = playerManager.playerLayer else { return }
        videoContainerView.layer.insertSublayer(playerLayer, below: videoThumbnailImageView.layer)
        playerLayer.frame = videoContainerView.bounds
    }

}

private extension VideoPreviewViewController {
    
    @objc func didTapDismiss() {
        playerManager.stop()
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func didTapSaveAsButton() {
        playerManager.togglePlayPause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.25) {
                self.videoThumbnailImageView.alpha = 0
            }
        }
    }
}
