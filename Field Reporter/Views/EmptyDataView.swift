//
//  EmptyDataView.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 27/06/25.
//

import UIKit

class EmptyDataView: UIView {
    
    private var emptyMessageLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    init(inputMessage : String) {
        super.init(frame: .zero)
        setupHierarchy()
        setupMessageLabel(inputMessage)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMessageLabel(_ message : String) {
        self.emptyMessageLabel.text = message
    }
    
    func setupHierarchy() {
        self.addSubview(emptyMessageLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyMessageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
}
