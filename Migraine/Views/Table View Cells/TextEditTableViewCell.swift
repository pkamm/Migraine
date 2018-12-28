//
//  TextEditTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 3/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

protocol EditDelegate: class {
    func editButtonPressed(_ questionInfo:QuestionInfo!)
}

class TextEditTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    weak var editDelegate: EditDelegate?
    weak var questionInfo: QuestionInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.layer.cornerRadius = 4
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.minorTextColor().cgColor
        editButton.setTitleColor(UIColor.minorTextColor(), for: .normal)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.majorTextColor()
        currentValueLabel.lineBreakMode = .byWordWrapping
        currentValueLabel.numberOfLines = 0
        currentValueLabel.textColor = UIColor.minorTextColor()
        backgroundColor = UIColor.darkBackgroundColor()
    }
    
    func setQuestionInfo(_ newQuestionInfo:QuestionInfo!) {
        questionInfo = newQuestionInfo
        self.addTitleText(newQuestionInfo.text)
        if let value = newQuestionInfo.value as? String {
            self.addValueText(value)
        }
    }
    
    func addTitleText(_ text:String) {
        let textString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: "SFProText-Semibold", size: 17)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.18
        textString.addAttribute(.paragraphStyle, value:paragraphStyle, range: textRange)
        titleLabel.attributedText = textString
        titleLabel.sizeToFit()
    }
    
    func addValueText(_ text:String?) {
        let displayValue = (text == nil) ? "" : text
        let textString = NSMutableAttributedString(string: displayValue!, attributes: [
            .font: UIFont(name: "SFProText-Regular", size: 15)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.33
        textString.addAttribute(.paragraphStyle, value:paragraphStyle, range: textRange)
        currentValueLabel.attributedText = textString
        currentValueLabel.sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.editDelegate?.editButtonPressed(questionInfo!)
    }
}
