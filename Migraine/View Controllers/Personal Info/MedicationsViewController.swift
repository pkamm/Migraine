//
//  MedicationsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 5/1/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class MedicationsViewController: UIViewController, SavablePage, DeleteDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    var isOnboarding = false

    @IBOutlet weak var addMedicationButton: UIButton!
    @IBOutlet weak var medicationTextField: UITextField!
    
    var medications = [String]()
    
    private let removeElementTableViewCellId = "removeElementTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMedicationButton.layer.cornerRadius = 8
        medicationTextField.layer.cornerRadius = 8
        medicationTextField.clipsToBounds = true
        saveButtonFooter.saveDelagate = self
        let removeElementNib = UINib(nibName: "RemoveElementTableViewCell", bundle: nil)
        tableView.register(removeElementNib, forCellReuseIdentifier: removeElementTableViewCellId)
        
        PatientInfoService.sharedInstance.getMedications(completion: { (medications) in
            if let serverMedications = medications {
                self.medications = serverMedications
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addMedicationButtonPressed(_ sender: UIButton) {
        if let newMedication = medicationTextField.text {
            medications.append(newMedication)
            medicationTextField.text = ""
            tableView.reloadData()
            medicationTextField.resignFirstResponder()
        }
    }
    
    // Mark TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: removeElementTableViewCellId,
                                                    for: indexPath) as? RemoveElementTableViewCell {
            cell.titleLabel.text = medications[indexPath.row]
            cell.deleteDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func delete(element: String?) {
        medications = medications.filter{$0 != element}
        tableView.reloadData()
    }
    
    func saveButtonPressed(_ sender: Any) {
        PatientInfoService.sharedInstance.save(medications: medications) {
            if self.isOnboarding {
                self.performSegue(withIdentifier: "OnboardingSymptomsSegue", sender: self)
            } else {
                self.showSavedAlert("Medications Saved!")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingVC = segue.destination as? SymptomsViewController {
            onboardingVC.isOnboarding = true
        }
    }

}
