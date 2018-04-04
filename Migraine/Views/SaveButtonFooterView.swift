//
//  SaveButtonFooterView.swift
//  Migraine
//
//  Created by Peter Kamm on 3/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

public protocol SavablePage: class {
    func saveButtonPressed(_ sender:Any)
}

class SaveButtonFooterView: UIView, NibFileOwnerLoadable {

    weak var saveDelagate: SavablePage?
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = loadNibContent()
        initSetup(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = loadNibContent()
        initSetup(view)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.saveDelagate?.saveButtonPressed(sender)
    }
    
    func initSetup(_ bgView:UIView?) {
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = UIColor.minorTextColor()
        saveButton.setTitleColor(UIColor.majorTextColor(), for: .normal)

        let textString = NSMutableAttributedString(string: "Save", attributes: [
            .font: UIFont(name: "SFProText-Semibold", size: 17)!,
            ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.29
        textString.addAttribute(.paragraphStyle, value:paragraphStyle, range: textRange)
        textString.addAttribute(.foregroundColor, value:UIColor.majorTextColor(), range: textRange)
        saveButton.setAttributedTitle(textString, for: .normal)
        bgView?.backgroundColor = UIColor.darkBackgroundColor()
    }

}
