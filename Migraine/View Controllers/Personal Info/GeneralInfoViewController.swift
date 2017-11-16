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
//        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
//        let datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
//        datePickerView.datePickerMode = UIDatePickerMode.Date
//        inputView.addSubview(datePickerView) // add date picker to UIView
//        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
//        doneButton.setTitle("Done", forState: UIControlState.Normal)
//        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
//        inputView.addSubview(doneButton) // add Button to UIView
//        doneButton.addTarget(self, action: #selector(GettingToKnowVC.doneNextPeriodButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
//        sender.inputView = inputView
//        datePickerView.addTarget(self, action: #selector(GettingToKnowVC.datePickerNextPeriodValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
//        datePickerNextPeriodValueChanged(datePickerView) // Set the date on start.
    }
    
    @IBAction func periodDateFocused(_ sender: UITextField) {
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

    }
    
    func addToolbarTo(picker: UIPickerView, title: String!, action: Selector?) -> UIToolbar {
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
        picker.dataSource = self
        picker.delegate = self
        return toolBar
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
    
    func save(infoDictionary: Dictionary<String, Any>) {
        
        
    }

}
