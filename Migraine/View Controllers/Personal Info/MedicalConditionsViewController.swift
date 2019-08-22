//
//  MedicalConditionsViewController.swift
//  Migraine
//
//  Created by Kamm, Peter on 12/7/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class MedicalConditionsViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {

    var conditions = ["Hypertension","Diabetes Mellitus","History of heart attack or coronary artery disease","History of stroke","Irritable bowel disease","Food Allergies","Depression","Anxiety","Panic disorder","Eating disorder","Schizophrenia or bipolar disorder","Obesity","Polycystic ovarian disorder","Attention deficit disorder","Hyperactivity disorder","Cancer"]
    
    var selectedConditions = [String]()
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    var isOnboarding = false

    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        if isOnboarding {
            saveButtonFooter.setTitle(title: "Next")
        } else {
            pageControl.isHidden = true
            saveButtonFooter.setTitle(title: "Save")
        }
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        
        PatientInfoService.sharedInstance.getMedicalConditions { (savedConditions) in
            if let serverSavedConditions = savedConditions,
                let serverConditions = serverSavedConditions["CONDITIONS"] as? [String] {
                self.selectedConditions = serverConditions
                for condition in self.selectedConditions {
                    if !self.conditions.contains(condition) {
                        self.conditions.append(condition)
                    }
                }
                for condition in serverConditions {
                    self.selectSavedCondition(condition)
                }
            }
        }
    }
    
    func selectSavedCondition(_ savedCondition:String) {
        for (rowNum, condition) in conditions.enumerated() {
            if savedCondition == condition {
                tableView.selectRow(at: IndexPath(row: rowNum, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        let conditionDictionary = ["CONDITIONS": selectedConditions]
        PatientInfoService.sharedInstance.saveUser(infoDictionary: conditionDictionary as [String : AnyObject])
        if isOnboarding {
            performSegue(withIdentifier: "OnboardingMedicationsSegue", sender: self)
        } else {
            showSavedAlert("Conditions Saved!")
        }
    }
    
    func showAddNewConditionAlert() {
        let alertBox = UIAlertController(title: "Medical Condition", message: nil, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = alertBox.textFields![0] as UITextField
            self.addNewCondition(textField.text)
        }))
        alertBox.addTextField { (textField) in
            textField.placeholder = "Condition"
        }
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alertBox, animated: true, completion: nil);
    }
    
    func addNewCondition(_ newCondition:String!) {
        if newCondition != "" {
            if !conditions.contains(newCondition) {
                conditions.append(newCondition)
                selectedConditions.append(newCondition)
                tableView.reloadData()
                for condition in selectedConditions {
                    self.selectSavedCondition(condition)
                }
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
        return conditions.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == conditions.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                cell.addTitleText(conditions[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(cell.isSelected, animated: false);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == conditions.count {
            showAddNewConditionAlert()
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            let condition = conditions[indexPath.row]
            selectedConditions.append(condition)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row < conditions.count {
            let condition = conditions[indexPath.row]
            if selectedConditions.contains(condition) {
                selectedConditions = selectedConditions.filter(){$0 != condition}
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingVC = segue.destination as? MedicationsViewController {
            onboardingVC.isOnboarding = true
        }
    }


}
