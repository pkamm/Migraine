//
//  SliderTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 8/8/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    weak var editDelegate: EditDelegate?
    weak var questionInfo: QuestionInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setQuestionInfo(_ newQuestionInfo:QuestionInfo!, scale:Int) {
        questionInfo = newQuestionInfo
        questionLabel.text = newQuestionInfo.text
        slider.maximumValue = Float(scale)
        slider.isContinuous = false
        sliderValueChanged(slider)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let fixedSliderValue = roundf(sender.value)
        sender.setValue(fixedSliderValue, animated: true)
        selectionLabel.text = questionInfo?.sliderLabels == nil ? String(fixedSliderValue) : questionInfo?.sliderLabels![Int(fixedSliderValue)]
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
