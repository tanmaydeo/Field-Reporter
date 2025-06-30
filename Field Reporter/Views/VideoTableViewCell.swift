//
//  VideoTableViewCell.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 28/06/25.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    private var videoInfoStackView : UIStackView = UIStackView()
    private var videoDescriptionStackView : UIStackView = UIStackView()
    private var videoImageView : UIImageView = UIImageView()
    private var videoTitleLabel : UILabel = UILabel()
    private var videoDescriptionLabel : UILabel = UILabel()
    private var videoDescriptionStackViewTopSpaceContainerView : UIView = UIView()
    private var videoDateTimeLabel : UILabel = UILabel()
    private var seperatorLineView : UIView = UIView()
    
    private let imageDarkOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.isUserInteractionEnabled = false
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    private let playImageOverlay : UIImageView = {
        let overlayImage = UIImageView()
        overlayImage.image = UIImage(named: "play")
        overlayImage.isUserInteractionEnabled = false
        overlayImage.translatesAutoresizingMaskIntoConstraints = false
        return overlayImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        setupHierarchy()
        setupStyles()
        setupConstraints()
    }
    
    func setupHierarchy() {
        contentView.addSubview(videoInfoStackView)
        contentView.addSubview(seperatorLineView)
        
        videoInfoStackView.addArrangedSubview(videoImageView)
        videoImageView.addSubview(imageDarkOverlay)
        videoImageView.addSubview(playImageOverlay)
        videoInfoStackView.addArrangedSubview(videoDescriptionStackView)
        
        videoDescriptionStackView.addArrangedSubview(videoDescriptionStackViewTopSpaceContainerView)
        videoDescriptionStackView.addArrangedSubview(videoTitleLabel)
        videoDescriptionStackView.addArrangedSubview(videoDescriptionLabel)
        videoDescriptionStackView.addArrangedSubview(videoDateTimeLabel)
    }
    
    func setupStyles() {
        setupStackViewStyles()
        setupImageStyling()
        setupLabelStyling()
    }
    
    func setupConstraints() {
        setupAutoresizingContranits()
        NSLayoutConstraint.activate([
            videoInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            videoInfoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            videoInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            videoInfoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            videoImageView.widthAnchor.constraint(equalToConstant: 90),
            videoImageView.heightAnchor.constraint(equalTo: videoImageView.widthAnchor, multiplier: 4/3),
            
            seperatorLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            seperatorLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            seperatorLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            seperatorLineView.heightAnchor.constraint(equalToConstant: 0.8),
            
            imageDarkOverlay.leadingAnchor.constraint(equalTo: videoImageView.leadingAnchor),
            imageDarkOverlay.trailingAnchor.constraint(equalTo: videoImageView.trailingAnchor),
            imageDarkOverlay.topAnchor.constraint(equalTo: videoImageView.topAnchor),
            imageDarkOverlay.bottomAnchor.constraint(equalTo: videoImageView.bottomAnchor),
            
            playImageOverlay.heightAnchor.constraint(equalToConstant: 24),
            playImageOverlay.widthAnchor.constraint(equalToConstant: 24),
            playImageOverlay.centerYAnchor.constraint(equalTo: videoImageView.centerYAnchor),
            playImageOverlay.centerXAnchor.constraint(equalTo: videoImageView.centerXAnchor)
        ])
    }
    
    func setupAutoresizingContranits() {
        videoInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
    }
}


//MARK: Styling functions
extension VideoTableViewCell {
    
    func setupStackViewStyles() {
        videoInfoStackView.axis = .horizontal
        videoInfoStackView.spacing = 12
        videoInfoStackView.alignment = .top
        videoInfoStackView.distribution = .fill
        
        videoDescriptionStackView.axis = .vertical
        videoDescriptionStackView.spacing = 8
        videoDescriptionStackView.alignment = .leading
    }
    
    func setupImageStyling() {
        videoImageView.layer.cornerRadius = 8
        videoImageView.clipsToBounds = true
    }
    
    func setupLabelStyling() {
        videoTitleLabel.textColor = .label
        videoTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        videoDescriptionLabel.textColor = UIColor.darkGray
        videoDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        videoDescriptionLabel.numberOfLines = 0
        
        videoDateTimeLabel.textColor = UIColor.darkGray
        videoDateTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        seperatorLineView.backgroundColor = AppColors.seperatorViewBackgroundColor
        seperatorLineView.layer.cornerRadius = seperatorLineView.frame.width / 2
        seperatorLineView.clipsToBounds = true
    }
    
    func configureCell(_ video : VideoModel) {
        //date: Date.now
        videoTitleLabel.text = video.title
        videoDescriptionLabel.text = video.description
        loadThumbnailImage(from: video.thumbnail)
        videoDateTimeLabel.text = formattedTimeAndDate(seconds: video.time, date: video.date)
    }
}


//Utility functions
extension VideoTableViewCell {
    
    private func loadThumbnailImage(from data: Data) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.videoImageView.image = image
            }
        } else {
            DispatchQueue.main.async {
                self.videoImageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    private func formattedTimeAndDate(seconds: Int32, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        
        let dateString = dateFormatter.string(from: date)
        return "\(seconds) sec, \(dateString)"
    }

}
