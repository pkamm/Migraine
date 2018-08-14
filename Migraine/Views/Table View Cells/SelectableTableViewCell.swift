//
//  SelectableTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 4/16/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class SelectableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.majorTextColor()
        backgroundColor = UIColor.darkBackgroundColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            checkmarkImage.image = #imageLiteral(resourceName: "checkRed")
        } else {
            checkmarkImage.image = #imageLiteral(resourceName: "checkGray")
        }
    }
    
    func addTitleText(_ text:String) {
        titleLabel.text = text
    }
    
}
