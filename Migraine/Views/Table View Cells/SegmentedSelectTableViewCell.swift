//
//  SegmentedSelectTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 3/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class SegmentedSelectTableViewCell: UITableViewCell, QuestionInfoTableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var editDelegate: EditDelegate?
    weak var questionInfo: QuestionInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.majorTextColor()
        segmentedControl.tintColor = UIColor.minorTextColor()
        backgroundColor = UIColor.darkBackgroundColor()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setQuestionInfo(_ newQuestionInfo:QuestionInfo!) {
        questionInfo = newQuestionInfo
        addTitleText(newQuestionInfo.text)
        if let value = newQuestionInfo.value as? String {
            addValueText(value)
        } else if let value = newQuestionInfo.value as? Bool {
            let valueText = value ? "Yes" : "No"
            addValueText(valueText)
        }
        segmentedControl.selectedSegmentIndex = 1
        selectedValueChanged(segmentedControl)
    }
    
    func addTitleText(_ text:String) {
        let textString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: "SFProText-Semibold", size: 19)!
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.18
        textString.addAttribute(.paragraphStyle, value:paragraphStyle, range: textRange)
        titleLabel.attributedText = textString
        titleLabel.sizeToFit()
    }
    
    func setSegmentedValues(_ values:[String]) {
        segmentedControl.removeAllSegments()
        for (index, value) in values.enumerated() {
            segmentedControl.insertSegment(withTitle: value, at: index, animated: false)
        }
        segmentedControl.apportionsSegmentWidthsByContent = true
    }
    
    func addValueText(_ text:String?) {
        for i in 0..<segmentedControl.numberOfSegments {
            if segmentedControl.titleForSegment(at: i) == text {
                segmentedControl.selectedSegmentIndex = i
            }
        }
    }
    
    func setEditDelegate(_ editDelegate: EditDelegate) {
        self.editDelegate = editDelegate
    }
    
    @IBAction func selectedValueChanged(_ sender: UISegmentedControl) {
        questionInfo?.value = sender.titleForSegment(at: sender.selectedSegmentIndex)
        editDelegate?.editButtonPressed(questionInfo)
    }
    
}
