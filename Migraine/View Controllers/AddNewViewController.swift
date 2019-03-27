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
    
    var diaryService:DiaryService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryService = DiaryService.sharedInstance
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
            self.migraineTableView.reloadData()
            if DiaryService.sharedInstance.getUnfinishedMigraineDiaryEntry() != nil {
                self.showMigraineFinishedAlert()
            }
        }
    }
    
    func showMigraineFinishedAlert(){
        let alert = UIAlertController(title: "Has your last migraine ended?",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "NewDiarySegueId", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Not Yet", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            let sorryAlert = UIAlertController(title: "Feel better soon (you can log this migraine when you are feeling better).",
                                               message: nil,
                                               preferredStyle: .alert)
            sorryAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler:nil))
            self.present(sorryAlert, animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryService!.diaryEntries.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryEntryTableViewCellId", for: indexPath) as? DiaryEntryTableViewCell {
            let diary = diaryService!.diaryEntries[indexPath.row]
            cell.configureWith(diary: diary)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let diary = diaryService!.diaryEntries[indexPath.row]
        performSegue(withIdentifier: "EditDiarySegue", sender: diary)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if segue.identifier == "EditDiarySegue" {
                if let destinationRoot = destination.viewControllers.first as? EditDiaryViewController,
                    let diary = sender as? DiaryEntry {
                    destinationRoot.editableDiaryEntry = diary
                }
            } else {
                if let unfinishedMigraineEntry = DiaryService.sharedInstance.getUnfinishedMigraineDiaryEntry() {
                    DiaryService.sharedInstance.pendingDiaryEntry = unfinishedMigraineEntry
                } else {
                    DiaryService.sharedInstance.pendingDiaryEntry = DiaryEntry()
                }
                if(DiaryService.sharedInstance.hasEnteredSleepDataToday()){
                    destination.viewControllers.first?.performSegue(withIdentifier: "StressSegue", sender: nil)
                }
            }
        }
    }
    
    func hasSavedSleepEntry() -> Bool {
        return false;
    }
    
    @IBAction func newMigraineButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Feel better soon (you can log this migraine when you are feeling better).",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let questionInfo = QuestionInfo(value: "yes", infoKey: .HADMIGRAINE)
            DiaryService.sharedInstance.submit(questionInfos: [questionInfo], date: Date(), completion:{})
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
}

class MigraineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var migraineIconImageView: UIImageView!
    @IBOutlet weak var migraineMainLabel: UILabel!
    @IBOutlet weak var migraineSecondaryLabel: UILabel!
    @IBOutlet weak var migraineDateLabel: UILabel!
    
}
