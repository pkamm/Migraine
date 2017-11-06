//
//  QuickAddMigraineViewController.swift
//  Migraine
//
//  Created by Kamm, Peter on 10/25/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class QuickAddMigraineViewController: UIViewController {

    var isQuickAddMigraine: Bool = true
    var dateFormatter:DateFormatter = DateFormatter()
    var datePicker: UIDatePicker! = UIDatePicker()
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nextButtonTitle = isQuickAddMigraine ? "Save" : "Next"
        continueButton.setTitle(nextButtonTitle, for: .normal)
        if isQuickAddMigraine { addCancelButton() }
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        datePicker.addTarget(self, action: #selector(QuickAddMigraineViewController.onDatePickerValueChanged), for: UIControlEvents.valueChanged)

        startTimeTextField.inputView = datePicker
        endTimeTextField.inputView = datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(QuickAddMigraineViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(QuickAddMigraineViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        endTimeTextField.inputAccessoryView = toolBar
        startTimeTextField.inputAccessoryView = toolBar
    }
    
    @objc func onDatePickerValueChanged(datePicker: UIDatePicker) {
        if startTimeTextField.isFirstResponder {
            startTimeTextField.text = dateFormatter.string(from: datePicker.date)
        }else{
            endTimeTextField.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    
    @objc func doneClick() {
        startTimeTextField.resignFirstResponder()
        endTimeTextField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        startTimeTextField.resignFirstResponder()
        endTimeTextField.resignFirstResponder()
    }
    
    func addCancelButton() {
        let backbutton = UIButton(type: .custom)
        backbutton.setTitle("Cancel", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action:#selector(self.cancelButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if isQuickAddMigraine {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "ContinueDiarySeque", sender: nil)
        }
    }
    
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
// 
//    }

}
