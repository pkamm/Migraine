//
//  AddNewViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/7/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class AddNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    

    @IBOutlet weak var newDiaryButton: UIButton!
    @IBOutlet weak var newMigraineButton: UIButton!
    
    @IBOutlet weak var migraineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newDiaryButton.layer.cornerRadius = 8;
        newMigraineButton.layer.cornerRadius = 8;
//        DiaryService.sharedInstance.getDiaryEntries { (entries) in
//            return
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0;
    }
    
    
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? UINavigationController {
            if(!isInMorning()){
                if let stressVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StressVC") as? StressViewController{
                    stressVC.cancelButton.isEnabled = true;
                    stressVC.cancelButton.tintColor = UIColor.lightText
                    destination.setViewControllers([stressVC], animated: false)
                }
            }
        }
    }
    
    func isInMorning()->Bool {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return (hour < 12)
    }

}

class MigraineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var migraineIconImageView: UIImageView!
    @IBOutlet weak var migraineMainLabel: UILabel!
    @IBOutlet weak var migraineSecondaryLabel: UILabel!
    @IBOutlet weak var migraineDateLabel: UILabel!
    
    
}
