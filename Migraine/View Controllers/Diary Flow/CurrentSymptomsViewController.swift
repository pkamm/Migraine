//
//  CurrentSymptomsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class CurrentSymptomsViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate  {

    var symptoms = [String]()
    var selectedSymptoms = [String]()
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
        setPageControl()
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        PatientInfoService.sharedInstance.getMedicalConditions { (savedSymptoms) in
            if let serverSavedSymptoms = savedSymptoms,
                let serverSymptoms = serverSavedSymptoms["SYMPTOMS"] as? [String] {
                self.symptoms = serverSymptoms
                self.tableView.reloadData()
            }
        }
    }
    
    func setPageControl(){
        var numberOfPages = 5
        numberOfPages += DiaryService.sharedInstance.hasEnteredSleepDataToday() ? 0 : 1
        do{
            numberOfPages += try (DiaryService.sharedInstance.pendingDiaryEntry?.wasMigraine())! ? 2 : 0
        } catch {}
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = numberOfPages - 4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addCurrentListToPendingDiaryEntry(infoKey: .SYMPTOMSTODAY, list: selectedSymptoms)
        performSegue(withIdentifier: "TriggersSegue", sender: sender)
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
                let symptomDictionary = ["SYMPTOMS": symptoms]
                PatientInfoService.sharedInstance.saveUser(infoDictionary: symptomDictionary as [String : AnyObject])
                selectedSymptoms.append(newSymptom)
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
                if( selectedSymptoms.contains(symptoms[indexPath.row]) ){
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
