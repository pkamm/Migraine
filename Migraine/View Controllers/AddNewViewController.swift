//
//  AddNewViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/7/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class AddNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newDiaryButton: UIButton!
    @IBOutlet weak var newMigraineButton: UIButton!
    @IBOutlet weak var migraineTableView: UITableView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var diaryEntries:[DiaryEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newDiaryButton.layer.cornerRadius = 8;
        newMigraineButton.layer.cornerRadius = 8;
        migraineTableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: (migraineTableView.tableHeaderView?.bounds.width)!, height: 48)
        buttonStackView?.frame = (migraineTableView.tableHeaderView?.frame)!
        buttonStackView.updateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("ReloadDiaryDataNotification"), object: nil)
        reloadData()
    }

    @objc func reloadData() {
        DiaryService.sharedInstance.getDiaryEntries { (entries) in
            self.diaryEntries = []
            for entry in entries! {
                self.diaryEntries.append(DiaryEntry(entry))
            }
            self.diaryEntries.sort(by: { $0.date > $1.date })
            self.migraineTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryEntries.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryEntryTableViewCellId", for: indexPath) as? DiaryEntryTableViewCell {
            let diary = diaryEntries[indexPath.row]
            cell.configureWith(diary: diary)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let diary = diaryEntries[indexPath.row]
        performSegue(withIdentifier: "EditDiarySegue", sender: diary)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if segue.identifier == "EditDiarySegue" {
                if let destinationRoot = destination.viewControllers.first as? EditDiaryViewController,
                    let diary = sender as? DiaryEntry {
                    destinationRoot.editableDiaryEntry = diary
                }
            } else if(!isInMorning()){
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
