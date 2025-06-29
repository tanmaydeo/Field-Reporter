//
//  PaddingLabel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//

import UIKit

class PaddedLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        return CGSize(width: sizeThatFits.width + textInsets.left + textInsets.right,
                      height: sizeThatFits.height + textInsets.top + textInsets.bottom)
    }
}
