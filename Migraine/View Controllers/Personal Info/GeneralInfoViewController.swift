//
//  GeneralInfoViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/16/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class GeneralInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var lmpDateTextField: UITextField!
    @IBOutlet weak var periodDateTextField: UITextField!
    @IBOutlet weak var birthControlTextField: UITextField!
    @IBOutlet weak var bornGenderTextField: UITextField!
    @IBOutlet weak var hormoneTextField: UITextField!
    
    private let dateFormatter = DateFormatter()
    
    let genderOptions = ["Female", "Male", "Other"]
    let birthControlOptions = ["None", "Estrogen/Progestin Pill", "Only Progestin Pill", "Patch", "Ring", "Progestin Shot", "Progestin Implant", "Hormone IUD", "Copper IUD"]
    let genderBornAsOptions = ["Female", "Male"]
    let hormoneTherapyOptions = ["Estrogen", "Testosterone"]
    
    var generalInfoDict = [String:String]()
    let maxUserAge = 120
    
    enum PickerViewTag: Int {
        case PickerViewAge
        case PickerViewGender
        case PickerViewBirthControl
        case PickerViewHormoneTherapy
        case PickerViewGenderBornAs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ageFieldFocused(_ sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.tag = PickerViewTag.PickerViewAge.rawValue
        sender.inputAccessoryView = addToolbarTo(picker: pickerView,
                                                 title:"Age",
                                                 action: #selector(GeneralInfoViewController.doneGenderPressed(sender:)))
        sender.inputView = pickerView
    }
    
    @IBAction func genderFieldFocused(_ sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.tag = PickerViewTag.PickerViewGender.rawValue
        sender.inputAccessoryView = addToolbarTo(picker: pickerView,
                                                 title:"Gender",
                                                 action: #selector(GeneralInfoViewController.doneGenderPressed(sender:)))
        sender.inputView = pickerView
    }
    
    @IBAction func lmpDateFocused(_ sender: UITextField) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(lmpDateChanged(_:)), for: .valueChanged)
        sender.inputAccessoryView = self.toolBarWith(title: "LMP", action: nil)
        sender.inputView = picker
    }
    
    @IBAction func periodDateFocused(_ sender: UITextField) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(nextPeriodDateChanged(_:)), for: .valueChanged)
        sender.inputAccessoryView = self.toolBarWith(title: "Last Period", action: nil)
        sender.inputView = picker
    }

    @IBAction func birthControlFocused(_ sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.tag = PickerViewTag.PickerViewBirthControl.rawValue
        sender.inputAccessoryView = addToolbarTo(picker: pickerView,
                                                 title:"Birth Control",
                                                 action: #selector(GeneralInfoViewController.doneGenderPressed(sender:)))
        sender.inputView = pickerView
    }
    
    @IBAction func bornGenderFocused(_ sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.tag = PickerViewTag.PickerViewGenderBornAs.rawValue
        sender.inputAccessoryView = addToolbarTo(picker: pickerView,
                                                 title:"Gender born as",
                                                 action: #selector(GeneralInfoViewController.doneGenderPressed(sender:)))
        sender.inputView = pickerView
    }
    
    @IBAction func hormoneFocused(_ sender: UITextField) {
        let pickerView = UIPickerView()
        pickerView.tag = PickerViewTag.PickerViewHormoneTherapy.rawValue
        sender.inputAccessoryView = addToolbarTo(picker: pickerView,
                                                 title:"Hormone Therapy",
                                                 action: #selector(GeneralInfoViewController.doneGenderPressed(sender:)))
        sender.inputView = pickerView
    }
    
    
    @objc func doneGenderPressed(sender: UIBarButtonItem) {
        //TODO
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
    
    func toolBarWith(title: String!, action: Selector?) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x:0, y:self.view.frame.size.height/6, width:self.view.frame.size.width, height:40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: action)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = title
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([textBtn,flexSpace,doneButton], animated: true)
        return toolBar
    }
    
    func addToolbarTo(picker: UIPickerView, title: String!, action: Selector?) -> UIToolbar {
        let toolBar = self.toolBarWith(title: title, action: action)
        picker.dataSource = self
        picker.delegate = self
        return toolBar
    }
    
    @objc func lmpDateChanged(_ datePicker: UIDatePicker) {
        self.lmpDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    @IBAction func nextPeriodDateChanged(_ datePicker: UIDatePicker) {
        self.periodDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case .PickerViewAge:
                return maxUserAge
            case .PickerViewGenderBornAs:
                return genderBornAsOptions.count
            case .PickerViewGender:
                return genderOptions.count
            case .PickerViewBirthControl:
                return birthControlOptions.count
            case .PickerViewHormoneTherapy:
                return hormoneTherapyOptions.count
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case .PickerViewAge:
                return String(row + 1)
            case .PickerViewGenderBornAs:
                return genderBornAsOptions[row]
            case .PickerViewGender:
                return genderOptions[row]
            case .PickerViewBirthControl:
                return birthControlOptions[row]
            case .PickerViewHormoneTherapy:
                return hormoneTherapyOptions[row]
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case .PickerViewAge:
                ageTextField.text = String(row + 1)
                generalInfoDict["AGE"] = ageTextField.text
            case .PickerViewGenderBornAs:
                bornGenderTextField.text = genderBornAsOptions[row]
                generalInfoDict["GENDERBORNAS"] = bornGenderTextField.text
            case .PickerViewGender:
                genderTextField.text = genderOptions[row]
                generalInfoDict["GENDER"] = genderTextField.text
            case .PickerViewBirthControl:
                birthControlTextField.text = birthControlOptions[row]
                generalInfoDict["BIRTHCONTROL"] = birthControlTextField.text
            case .PickerViewHormoneTherapy:
                hormoneTextField.text = hormoneTherapyOptions[row]
                generalInfoDict["HORMONETHERAPY"] = hormoneTextField.text
            }
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let userInfoDictionary: [String: String?] = [
            "AGE": ageTextField.text,
            "GENDER": genderTextField.text,
            "NEXTPERIOD": periodDateTextField.text,
            "LMP": lmpDateTextField.text,
            "BIRTHCONTROL": birthControlTextField.text,
            "GENDERBORNAS": bornGenderTextField.text,
            "HORMONETHERAPY": hormoneTextField.text
            ]

        DataService.sharedInstance.saveUser(infoDictionary: userInfoDictionary)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func save(infoDictionary: Dictionary<String, Any>) {
        
        
    }

}
