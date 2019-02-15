//
//  CurrentTriggersViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class CurrentTriggersViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    var triggers = [String]()
    var selectedTriggers = [String]()
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        PatientInfoService.sharedInstance.getMedicalConditions { (savedTrigger) in
            if let serverSavedTrigger = savedTrigger,
                let serverTrigger = serverSavedTrigger["TRIGGERS"] as? [String] {
                self.triggers = serverTrigger
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addCurrentListToPendingDiaryEntry(infoKey: .TRIGGERSTODAY, list: selectedTriggers)
        performSegue(withIdentifier: "HelpersSegue", sender: sender)
    }
    
    func showAddNewTriggerAlert() {
        let alertBox = UIAlertController(title: "Trigger", message: nil, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = alertBox.textFields![0] as UITextField
            self.addNewTrigger(textField.text)
        }))
        alertBox.addTextField { (textField) in
            textField.placeholder = "Trigger"
        }
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alertBox, animated: true, completion: nil);
    }
    
    func addNewTrigger(_ newTrigger:String!) {
        if newTrigger != "" {
            if !triggers.contains(newTrigger) {
                triggers.append(newTrigger)
                let triggerDictionary = ["TRIGGERS": triggers]
                PatientInfoService.sharedInstance.saveUser(infoDictionary: triggerDictionary as [String : AnyObject])
                selectedTriggers.append(newTrigger)
                tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "The item you tried to add is already in the list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Mark TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triggers.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == triggers.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                cell.addTitleText(triggers[indexPath.row])
                if( selectedTriggers.contains(triggers[indexPath.row]) ){
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(cell.isSelected, animated: false);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == triggers.count {
            showAddNewTriggerAlert()
        } else {
            let trigger = triggers[indexPath.row]
            selectedTriggers.append(trigger)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let trigger = triggers[indexPath.row]
        if selectedTriggers.contains(trigger) {
            selectedTriggers = selectedTriggers.filter(){$0 != trigger}
        }
    }
    
}
