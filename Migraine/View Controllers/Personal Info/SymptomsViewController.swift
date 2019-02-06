//
//  SymptomsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 4/25/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class SymptomsViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {

    var symptoms = ["Sensitivity to Light", "Sensitivity to Sound", "Sensitivity to Smells","Fatigue", "Nausea", "Vomiting","Dizziness", "Body Pain", "Abdominal Pain", "Moodiness/Irritability", "Cravings",  "Decreased Appetite", "Fever", "Pallor", "Feeling Hot or Cold",  "Seizures", "Tinnitus (ringing in the ears)", "Weakness in an Arm or a Leg"]
    
    var selectedSymptoms = [String]()
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        
        PatientInfoService.sharedInstance.getMedicalConditions { (savedSymptoms) in
            if let serverSavedSymptoms = savedSymptoms,
                let serverSymptoms = serverSavedSymptoms["SYMPTOMS"] as? [String] {
                self.selectedSymptoms = serverSymptoms
                for symptom in self.selectedSymptoms {
                    if !self.symptoms.contains(symptom) {
                        self.symptoms.append(symptom)
                    }
                }
                for symptom in serverSymptoms {
                    self.selectSavedSymptom(symptom)
                }
            }
        }
    }
    
    func selectSavedSymptom(_ savedSymptom:String) {
        for (rowNum, symptom) in symptoms.enumerated() {
            if savedSymptom == symptom {
                tableView.selectRow(at: IndexPath(row: rowNum, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        let symptomDictionary = ["SYMPTOMS": selectedSymptoms]
        PatientInfoService.sharedInstance.saveUser(infoDictionary: symptomDictionary as [String : AnyObject])
    
        let alert = UIAlertController(title: "\n\n\nSymptoms Saved!", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(action)
        alert.addCheckMark()
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAddNewSymptomAlert() {
        let alertBox = UIAlertController(title: "Symptom", message: nil, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = alertBox.textFields![0] as UITextField
            self.addNewSymptom(textField.text)
        }))
        alertBox.addTextField { (textField) in
            textField.placeholder = "Symptom"
        }
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alertBox, animated: true, completion: nil);
    }
    
    func addNewSymptom(_ newSymptom:String!) {
        if newSymptom != "" {
            if !symptoms.contains(newSymptom) {
                symptoms.append(newSymptom)
                selectedSymptoms.append(newSymptom)
                tableView.reloadData()
                for symptom in selectedSymptoms {
                    self.selectSavedSymptom(symptom)
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
        return symptoms.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == symptoms.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                cell.addTitleText(symptoms[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(cell.isSelected, animated: false);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == symptoms.count {
            showAddNewSymptomAlert()
        } else {
            let symptom = symptoms[indexPath.row]
            selectedSymptoms.append(symptom)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let symptom = symptoms[indexPath.row]
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms = selectedSymptoms.filter(){$0 != symptom}
        }
    }

}
