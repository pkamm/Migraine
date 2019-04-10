//
//  RemoveElementTableViewCell.swift
//  Migraine
//
//  Created by Peter Kamm on 8/10/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

protocol DeleteDelegate: class {
    func delete(element: Any?)
}

class MedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    
    weak var deleteDelegate:DeleteDelegate?
    var medication:Medication?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMedication(_ medication:Medication){
        self.medication = medication
        titleLabel.text = medication.name
        let dosageText = medication.dosage + ", " + medication.frequency.description
        dosageLabel.text = dosageText
    }
    
    @IBAction func removeButtonPressed(_ sender: Any) {
        deleteDelegate?.delete(element: medication)
    }
}
