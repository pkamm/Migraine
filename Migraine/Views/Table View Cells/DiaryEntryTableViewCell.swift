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
    @IBOutlet weak var stressLevelLabel: UILabel!
    @IBOutlet weak var migraineLabel: UILabel!
    @IBOutlet weak var migraineImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWith(diary:DiaryEntry){
        do{
            dateLabel.text = DiaryService.sharedInstance.dateFormatterShort.string(from: diary.date)
            migraineImage.layer.cornerRadius = 8
            migraineLabel.text = diary.migraineSeverityText()

            if try diary.wasMigraine(){
                migraineImage.image = UIImage(named: "icon_lighting")!.withAlignmentRectInsets(UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6))
                migraineImage.backgroundColor = UIColor(red:0.79, green:0.79, blue:0.79, alpha:1)
            } else {
                migraineImage.image = UIImage(named: "icon_smile")!.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
                migraineImage.backgroundColor = UIColor(red:0.17, green:0.15, blue:0.15, alpha:1)
            }
            
        } catch {
            migraineLabel.text = ""
            
        }
    }

}
