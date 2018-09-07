//
//  DiaryEntryTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 9/7/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class DiaryEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
