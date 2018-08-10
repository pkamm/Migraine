//
//  RemoveElementTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 8/10/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

protocol DeleteDelegate: class {
    func delete(element: String?)
}

class RemoveElementTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    weak var deleteDelegate:DeleteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeButtonPressed(_ sender: Any) {
        deleteDelegate?.delete(element: titleLabel.text)
    }
}
