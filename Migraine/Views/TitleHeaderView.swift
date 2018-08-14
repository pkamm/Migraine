//
//  TitleHeaderView.swift
//  Migraine
//
//  Created by Peter Kamm on 3/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class TitleHeaderView: UIView, NibFileOwnerLoadable {

    @IBOutlet weak var titleLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setTitle(_ title:String) {
        titleLabel.textColor = UIColor.majorTextColor()
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        backgroundColor = UIColor.darkBackgroundColor()
        let textString = NSMutableAttributedString(string: title, attributes: [
            .font: UIFont(name: "SFProText-Semibold", size: 18)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.41
        textString.addAttribute(.paragraphStyle, value:paragraphStyle, range: textRange)
        titleLabel.attributedText = textString
        titleLabel.sizeToFit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
