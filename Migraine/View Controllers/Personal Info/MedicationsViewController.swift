//
//  MedicationsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 5/1/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class MedicationsViewController: UIViewController, SavablePage, DeleteDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    var isOnboarding = false
    var selectedFrequency:MedicationFrequency? = nil

    @IBOutlet weak var addMedicationButton: UIButton!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var dosageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var medications = [Medication]()
    
    private let medicationTableViewCellId = "MedicationTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatView(addMedicationButton)
        formatView(medicationTextField)
        formatView(frequencyTextField)
        formatView(dosageTextField)
        let picker = UIPickerView()
        frequencyTextField.inputView = picker
        saveButtonFooter.saveDelagate = self
        if isOnboarding {
            saveButtonFooter.setTitle(title: "Next")
        } else {
            pageControl.isHidden = true
            saveButtonFooter.setTitle(title: "Save")
        }
        addDoneButtonOnKeyboard()
        frequencyTextField.inputAccessoryView = addToolbarTo(picker: picker, title: "Frequency", action: #selector(MedicationsViewController.donePressed(sender:)))
        let removeElementNib = UINib(nibName: "MedicationTableViewCell", bundle: nil)
        tableView.register(removeElementNib, forCellReuseIdentifier: medicationTableViewCellId)
        PatientInfoService.sharedInstance.getMedications(completion: { (medications) in
            if let serverMedications = medications {
                self.medications = serverMedications
                self.tableView.reloadData()
            }
        })
    }
    
    func formatView(_ formatView:UIView) {
        formatView.layer.cornerRadius = 8
        formatView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addMedicationButtonPressed(_ sender: UIButton) {
        if let medicationName = medicationTextField.text,
            let medicationFrequency = selectedFrequency,
            let medicationDosage = dosageTextField.text {
            let dosageText = medicationDosage + " " + dosageSegmentedControl.titleForSegment(at: dosageSegmentedControl.selectedSegmentIndex)!
                let newMedication = Medication(medicationName, frequency: medicationFrequency, dosage: dosageText)
                medications.append(newMedication)
            
            //reset fields
            medicationTextField.text = ""
            dosageTextField.text = ""
            frequencyTextField.text = ""
                tableView.reloadData()
                medicationTextField.resignFirstResponder()
        } else {
            //alert
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: medicationTableViewCellId,
                                                    for: indexPath) as? MedicationTableViewCell {
            cell.setMedication(medications[indexPath.row])
            cell.deleteDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func delete(element: Any?) {
        if let deleteMedication = element as? Medication {
            self.medications = self.medications.filter({ (medication) -> Bool in
                return deleteMedication.name != medication.name
            })
        }
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
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MedicationsViewController.donePressed(sender:)))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        dosageTextField.inputAccessoryView = doneToolbar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        frequencyTextField.becomeFirstResponder()
        return true
    }
    
    // Picker stuff
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MedicationFrequency.asArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MedicationFrequency.asArray[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frequencyTextField.text = MedicationFrequency.asArray[row].description
        selectedFrequency = MedicationFrequency.asArray[row]
    }

    @objc func donePressed(sender: UIBarButtonItem) {
        if frequencyTextField.isFirstResponder {
            dosageTextField.becomeFirstResponder()
        } else {
            frequencyTextField.resignFirstResponder()
            dosageTextField.resignFirstResponder()
        }
    }

    func addToolbarTo(picker: UIPickerView, title: String!, action: Selector?) -> UIToolbar {
        let toolBar = self.toolBarWith(title: title, action: action)
        picker.dataSource = self
        picker.delegate = self
        return toolBar
    }


}
