//
//  CurrentPreventionsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class CurrentPreventionsViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    var helpers = [String]()
    var selectedHelpers = [String]()
    
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
        PatientInfoService.sharedInstance.getMedicalConditions { (savedHelper) in
            if let savedServerHelper = savedHelper,
                let serverHelper = savedServerHelper["HELPMIGRAINE"] as? [String] {
                self.helpers = serverHelper
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addCurrentListToPendingDiaryEntry(infoKey: .HELPMIGRAINETODAY, list: selectedHelpers)
        DiaryService.sharedInstance.submitPendingDiaryEntry {
            self.performSegue(withIdentifier: "SuccessSegue", sender: nil)
        }
    }
    
    func showAddNewHelperAlert() {
        let alertBox = UIAlertController(title: "Helper", message: nil, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = alertBox.textFields![0] as UITextField
            self.addNewHelper(textField.text)
        }))
        alertBox.addTextField { (textField) in
            textField.placeholder = "Helper"
        }
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alertBox, animated: true, completion: nil);
    }
    
    func addNewHelper(_ newHelper:String!) {
        if newHelper != "" {
            if !helpers.contains(newHelper) {
                self.helpers.append(newHelper)
                let helperDictionary = ["HELPMIGRAINE": self.helpers]
                PatientInfoService.sharedInstance.saveUser(infoDictionary: helperDictionary as [String : AnyObject])
                selectedHelpers.append(newHelper)
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
        return helpers.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == helpers.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                cell.addTitleText(helpers[indexPath.row])
                if( selectedHelpers.contains(helpers[indexPath.row]) ){
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
        if indexPath.row == helpers.count {
            showAddNewHelperAlert()
        } else {
            let helper = helpers[indexPath.row]
            selectedHelpers.append(helper)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let helper = helpers[indexPath.row]
        if selectedHelpers.contains(helper) {
            selectedHelpers = selectedHelpers.filter(){$0 != helper}
        }
    }

}
