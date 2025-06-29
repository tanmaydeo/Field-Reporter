//
//  VideoPreviewViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 28/06/25.
//

import UIKit

class VideoPreviewViewController: UIViewController {

    var videoURL : URL
    
    private let dismissButton = UIButton(type: .system)
    private let videoPlayerView : UIView = UIView()
    private let saveAsButton : RedCustomButton = RedCustomButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    init(videoURL : URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupHierarchy() {
        view.addSubview(dismissButton)
        view.addSubview(videoPlayerView)
        view.addSubview(saveAsButton)
    }
    
    private func setupStyles() {
        view.backgroundColor = .systemBackground
        
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .label
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        //VideoPlayerView
        videoPlayerView.backgroundColor = .black
        
        //saveAsButton
        saveAsButton.setTitle("Save as", for: .normal)
    }

    private func setupConstraints() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        saveAsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 12),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlayerView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 16),
            videoPlayerView.bottomAnchor.constraint(equalTo: saveAsButton.topAnchor, constant: -16),
            
            saveAsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveAsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveAsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            saveAsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension VideoPreviewViewController {
    
    @objc func dismissView() {
        self.navigationController?.popViewController(animated: false)
    }
    
}
