//
//  GeneralInfoViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 3/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class GeneralInfoViewController: StandardBaseClassStyle, SavablePage, EditDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    
    private let dateFormatter = DateFormatter()
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How old are you?", infoKey: InfoKey.AGE),
        QuestionInfo(text: "Gender", infoKey: InfoKey.GENDER),
        QuestionInfo(text: "What gender were you born as?", infoKey: InfoKey.GENDERBORNAS),
        QuestionInfo(text: "Any hormore therapy?", infoKey: InfoKey.HORMONETHERAPY),
        QuestionInfo(text: "Date of LMP", infoKey: InfoKey.LMP),
        QuestionInfo(text: "Anticipated date of next period", infoKey: InfoKey.NEXTPERIOD),
        QuestionInfo(text: "Methods of birth control", infoKey: InfoKey.BIRTHCONTROL)]
    
    private let genderOptions = ["Female", "Male", "Other"]
    private let birthControlOptions = ["None", "Estrogen/Progestin Pill", "Only Progestin Pill", "Patch", "Ring", "Progestin Shot", "Progestin Implant", "Hormone IUD", "Copper IUD"]
    private let genderBornAsOptions = ["Female", "Male"]
    private let hormoneTherapyOptions = ["None", "Estrogen", "Testosterone"]
    
    private var currentQuestionInfo: QuestionInfo?
    private var isMaleSelected: Bool = false
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
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
        saveButtonFooter.saveDelagate = self
        dateFormatter.dateStyle = .medium
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        tableView.backgroundColor = UIColor.darkBackgroundColor()
        PatientInfoService.sharedInstance.getMedicalConditions { (conditionsDictionary) in
            self.updateTextFields(healthDictionary: conditionsDictionary!)
        }
    }
    
    func updateTextFields(healthDictionary: [String:AnyObject?]) {
        for (healthKey, healthValue) in healthDictionary {
            if let healthV = healthValue as? String, healthV != "" {
                do {
                    let userInfoKey = InfoKey(rawValue: healthKey)
                    if let questionInfo = try questionInfoFor(userInfoKey: userInfoKey!){
                        questionInfo.value = healthV;
                        if (questionInfo.value == "Male") && (userInfoKey == InfoKey.GENDERBORNAS) {
                            isMaleSelected = true
                        }
                    }
                } catch {
                    print("damn")
                }
            }
        }
        tableView.reloadData()
    }
    
    func questionInfoFor(userInfoKey: InfoKey) throws -> QuestionInfo? {
        for questionInfo in questionInfoArray {
            if questionInfo.infoKey == userInfoKey {
                return questionInfo
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        var userInfoDictionary = [String: String?]()
        for (index, questionInfo) in questionInfoArray.enumerated() {
            userInfoDictionary[questionInfo.infoKey.rawValue] = questionInfo.value
            if (index == 3 && isMaleSelected) { break }
        }
        PatientInfoService.sharedInstance.saveUser(infoDictionary: userInfoDictionary as [String : AnyObject])
        
        let alert = UIAlertController(title: "\n\n\nInfo Saved!", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(action)
        alert.addCheckMark()
        self.present(alert, animated: true, completion: nil)
    }
    
    // Mark TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMaleSelected {
            return 4
        } else {
            return self.questionInfoArray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionInfo = questionInfoArray[indexPath.row]
        switch questionInfo.infoKey {
        case .AGE, .BIRTHCONTROL, .HORMONETHERAPY, .LMP, .NEXTPERIOD:
            if let cell = tableView.dequeueReusableCell(withIdentifier: self.textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
        case .GENDER, .GENDERBORNAS:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.segmentedSelectTableViewCellId, for: indexPath) as! SegmentedSelectTableViewCell
            let segmentValues = questionInfo.infoKey == .GENDER ? genderOptions : genderBornAsOptions
            cell.setSegmentedValues(segmentValues)
            cell.setQuestionInfo(questionInfo)
            cell.editDelegate = self
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    
    // picker
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .GENDERBORNAS:
            isMaleSelected = (questionInfo.value == "Male")
            tableView.reloadData()
            return
        case .AGE:
            createPicker(title: "Age")
        case .BIRTHCONTROL:
            createPicker(title: "Birth Control")
        case .HORMONETHERAPY:
            createPicker(title: "Hormone Therapy")
        case .LMP:
            createDatePicker(title: "LMP")
        case .NEXTPERIOD:
            createDatePicker(title: "Last Period")
        default:
            return;
        }
        globalInputTextField.becomeFirstResponder()
    }
    
    func createPicker(title:String) {
        let pickerView = UIPickerView()
        globalInputTextField.inputAccessoryView =
            addToolbarTo(picker: pickerView,
                         title:title,
                         action: #selector(GeneralInfoViewController.donePressed(sender:)))
        globalInputTextField.inputView = pickerView
    }
    
    func createDatePicker(title:String) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        pickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        globalInputTextField.inputAccessoryView =
            toolBarWith(title:title,
                         action: #selector(GeneralInfoViewController.donePressed(sender:)))
        globalInputTextField.inputView = pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let questionInfo = currentQuestionInfo {
            switch questionInfo.infoKey {
            case .AGE:
                return maxUserAge
            case .BIRTHCONTROL:
                return birthControlOptions.count
            case .HORMONETHERAPY:
                return hormoneTherapyOptions.count
            default:
                return 0
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let questionInfo = currentQuestionInfo {
            switch questionInfo.infoKey {
            case .AGE:
                return String(row + 1)
            case .BIRTHCONTROL:
                return birthControlOptions[row]
            case .HORMONETHERAPY:
                return hormoneTherapyOptions[row]
            default:
                return nil
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let questionInfo = currentQuestionInfo {
            switch questionInfo.infoKey {
            case .AGE:
                currentQuestionInfo?.value = String(row + 1)
            case .BIRTHCONTROL:
                currentQuestionInfo?.value = birthControlOptions[row]
            case .HORMONETHERAPY:
                currentQuestionInfo?.value = hormoneTherapyOptions[row]
            default:
                return
            }
        }
        tableView.reloadData()
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        currentQuestionInfo?.value = dateFormatter.string(from: datePicker.date)
        tableView.reloadData()
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        globalInputTextField.resignFirstResponder()
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
}
