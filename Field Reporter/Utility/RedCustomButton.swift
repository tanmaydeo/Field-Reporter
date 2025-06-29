//
//  RedCustomButton.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import Foundation
import UIKit

class RedCustomButton: UIButton {
    
    var buttonBorderWidth: CGFloat = 0.01
    var buttonBorderColor = UIColor.white.cgColor
    var titleLabelFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.red
        self.addCornerRadius(self.frame.height/2)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = titleLabelFont
    }
    
}
