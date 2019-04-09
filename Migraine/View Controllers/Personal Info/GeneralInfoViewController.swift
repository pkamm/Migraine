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
        QuestionInfo(text: "Date of LMP", infoKey: InfoKey.LMP),
        QuestionInfo(text: "Anticipated date of next period", infoKey: InfoKey.NEXTPERIOD),
        QuestionInfo(text: "Methods of birth control", infoKey: InfoKey.BIRTHCONTROL)]
    
    private let genderOptions = ["Female", "Male"]
    private let birthControlOptions = ["None", "Estrogen/Progestin Pill", "Only Progestin Pill", "Patch", "Ring", "Progestin Shot", "Progestin Implant", "Hormone IUD", "Copper IUD"]
    private let genderBornAsOptions = ["Female", "Male"]
    private let hormoneTherapyOptions = ["None", "Estrogen", "Testosterone"]
    
    private var currentQuestionInfo: QuestionInfo?
    private var isMaleSelected: Bool = false
    var isOnboarding = false
    
    @IBOutlet weak var saveButtonHeight: NSLayoutConstraint!
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
        if isOnboarding {
            saveButtonHeight.constant = 110
        }
        saveButtonFooter.saveDelagate = self
        dateFormatter.dateStyle = .medium
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        tableView.backgroundColor = UIColor.darkBackgroundColor()
        let saveButtonText = isOnboarding ? "Next" : "Save"
        saveButtonFooter.setTitle(title: saveButtonText)
        PatientInfoService.sharedInstance.getMedicalConditions { (conditionsDictionary) in
            if let conditionsDict = conditionsDictionary {
                self.updateTextFields(healthDictionary: conditionsDict)
            }
        }
    }

    func updateTextFields(healthDictionary: [String:AnyObject?]) {
        for (healthKey, healthValue) in healthDictionary {
            if let healthV = healthValue as? String, healthV != "" {
                do {
                    let userInfoKey = InfoKey(rawValue: healthKey)
                    if let questionInfo = try questionInfoFor(userInfoKey: userInfoKey!){
                        questionInfo.value = healthV;
                        if let value = questionInfo.value as? String,
                            (value == "Male") && (userInfoKey == InfoKey.GENDER) {
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
            if let value = questionInfo.value as? String {
                userInfoDictionary[questionInfo.infoKey.rawValue] = value
            }
            if (index == 1 && isMaleSelected) { break }
        }
        PatientInfoService.sharedInstance.saveUser(infoDictionary: userInfoDictionary as [String : AnyObject])
        if isOnboarding {
            performSegue(withIdentifier: "OnboardingMedicalInfoSegue", sender: self)
        } else {
            showSavedAlert("Info Saved")
        }
    }
    
    // Mark TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMaleSelected {
            return 2
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
        case .AGE, .BIRTHCONTROL, .LMP, .NEXTPERIOD:
            if let cell = tableView.dequeueReusableCell(withIdentifier: self.textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
        case .GENDER:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.segmentedSelectTableViewCellId, for: indexPath) as! SegmentedSelectTableViewCell
            let segmentValues = genderOptions
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
        case .GENDER:
            if let value = self.currentQuestionInfo?.value as? String {
                isMaleSelected = (value == "Male")
            }
            tableView.reloadData()
            return
        case .AGE:
            createPicker(title: "Age")
            break
        case .BIRTHCONTROL:
            createPicker(title: "Birth Control")
            break
        case .HORMONETHERAPY:
            createPicker(title: "Hormone Therapy")
            break
        case .LMP:
            createDatePicker(title: "LMP")
            break
        case .NEXTPERIOD:
            createDatePicker(title: "Last Period")
            break
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
    
    func addToolbarTo(picker: UIPickerView, title: String!, action: Selector?) -> UIToolbar {
        let toolBar = self.toolBarWith(title: title, action: action)
        picker.dataSource = self
        picker.delegate = self
        return toolBar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingVC = segue.destination as? MedicalConditionsViewController {
            onboardingVC.isOnboarding = true
        }
    }
}

