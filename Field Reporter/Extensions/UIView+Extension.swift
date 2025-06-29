//
//  UIView+Extension.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//


import UIKit

extension UIView {
    func addCornerRadius(_ cornerRadius : CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
