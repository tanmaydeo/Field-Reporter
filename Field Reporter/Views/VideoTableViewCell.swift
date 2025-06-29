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
    private var videoTimeLabel : UILabel = UILabel()
    private var seperatorLineView : UIView = UIView()
    
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
        videoInfoStackView.addArrangedSubview(videoDescriptionStackView)
        
        videoDescriptionStackView.addArrangedSubview(videoDescriptionStackViewTopSpaceContainerView)
        videoDescriptionStackView.addArrangedSubview(videoTitleLabel)
        videoDescriptionStackView.addArrangedSubview(videoDescriptionLabel)
        videoDescriptionStackView.addArrangedSubview(videoTimeLabel)
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
            seperatorLineView.heightAnchor.constraint(equalToConstant: 0.5)
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
        videoImageView.image = UIImage(named: "placeholder")
        videoImageView.layer.cornerRadius = 8
        videoImageView.clipsToBounds = true
    }
    
    func setupLabelStyling() {
        videoTitleLabel.textColor = .label
        videoTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        videoDescriptionLabel.textColor = UIColor.darkGray
        videoDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        videoDescriptionLabel.numberOfLines = 3
        
        videoTimeLabel.text = "34 sec"
        videoTimeLabel.textColor = UIColor.darkGray
        videoTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        videoDescriptionStackViewTopSpaceContainerView.backgroundColor = .blue
        
        seperatorLineView.backgroundColor = AppColors.seperatorViewBackgroundColor
        seperatorLineView.layer.cornerRadius = seperatorLineView.frame.width / 2
        seperatorLineView.clipsToBounds = true
    }
    
    func configureCell(_ video : VideoModel) {
        videoTitleLabel.text = video.title
        videoDescriptionLabel.text = video.description
    }
}
