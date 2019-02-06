//
//  HelpersViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 4/24/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class HelpersViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    
    var selectedHelpers = [String]()
    var helpers = ["Sleep", "Medications", "Exercise", "Drinking Water", "Caffeine", "Chocolate", "Glasses to Prevent Glare", "Yoga"]

    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButtonFooter.saveDelagate = self
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        
        PatientInfoService.sharedInstance.getMedicalConditions { (savedHelpers) in
            if let serverSavedHelpers = savedHelpers,
                let serverHelpers = serverSavedHelpers["HELPMIGRAINE"] as? [String] {
                self.selectedHelpers = serverHelpers
                for helper in self.selectedHelpers {
                    if !self.helpers.contains(helper) {
                        self.helpers.append(helper)
                    }
                }
                for helper in serverHelpers {
                    self.selectSavedHelper(helper)
                }
            }
        }
    }
    
    func selectSavedHelper(_ savedHelper:String) {
        for (rowNum, helper) in helpers.enumerated() {
            if savedHelper == helper {
                tableView.selectRow(at: IndexPath(row: rowNum, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    func saveButtonPressed(_ sender: Any) {
        let helperDictionary = ["HELPMIGRAINE": selectedHelpers]
        PatientInfoService.sharedInstance.saveUser(infoDictionary: helperDictionary as [String : AnyObject])
        
        let alert = UIAlertController(title: "\n\n\nHelpers Saved!", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(action)
        alert.addCheckMark()
        self.present(alert, animated: true, completion: nil)
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
                helpers.append(newHelper)
                selectedHelpers.append(newHelper)
                tableView.reloadData()
                for helper in selectedHelpers {
                    self.selectSavedHelper(helper)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "The item you tried to add is already in the list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
