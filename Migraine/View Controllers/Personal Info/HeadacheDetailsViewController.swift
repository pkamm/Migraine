//
//  HeadacheDetailsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 2/15/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit

class HeadacheDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    
    private let dateFormatter = DateFormatter()
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How long does your typical headache last?", infoKey: .HEADACHEDURATION),
        QuestionInfo(text: "What side is your headache typically on?", infoKey: .HEADACHESIDE),
        QuestionInfo(text: "Do you typically get aura?", infoKey: .GETAURA),
        QuestionInfo(text: "Describe your aura", infoKey: .AURANOTES)]
    
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
      //  saveButtonFooter.saveDelagate = self
        dateFormatter.dateStyle = .medium
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        tableView.backgroundColor = UIColor.darkBackgroundColor()
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
                            (value == "Male") && (userInfoKey == InfoKey.GENDERBORNAS) {
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
//        case .AGE, .BIRTHCONTROL, .HORMONETHERAPY, .LMP, .NEXTPERIOD:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: self.textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
//                cell.setQuestionInfo(questionInfo)
//                cell.editDelegate = self
//                return cell
//            }
//        case .GENDER, .GENDERBORNAS:
//            let cell = tableView.dequeueReusableCell(withIdentifier: self.segmentedSelectTableViewCellId, for: indexPath) as! SegmentedSelectTableViewCell
//            let segmentValues = questionInfo.infoKey == .GENDER ? genderOptions : genderBornAsOptions
//            cell.setSegmentedValues(segmentValues)
//            cell.setQuestionInfo(questionInfo)
//            cell.editDelegate = self
//            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    
    // picker
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .GENDERBORNAS:
            if let value = self.currentQuestionInfo?.value as? String {
                isMaleSelected = (value == "Male")
            }
            tableView.reloadData()
            return
//        case .AGE:
//            createPicker(title: "Age")
//        case .BIRTHCONTROL:
//            createPicker(title: "Birth Control")
//        case .HORMONETHERAPY:
//            createPicker(title: "Hormone Therapy")
//        case .LMP:
//            createDatePicker(title: "LMP")
//        case .NEXTPERIOD:
//            createDatePicker(title: "Last Period")
        default:
            return;
        }
        globalInputTextField.becomeFirstResponder()
    }
    
//    func editButtonPressed(_ questionInfo:QuestionInfo!) {
//        currentQuestionInfo = questionInfo
//        switch questionInfo.infoKey {
//        case .SLEEPDURATIONMINUTES:
//            createDurationPicker(title: "Sleep Duration")
//            globalInputTextField.becomeFirstResponder()
//            break
//        default:
//            return;
//        }
//    }
    
    func createDurationPicker(title:String) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .countDownTimer
        pickerView.minuteInterval = 5
        pickerView.addTarget(self, action: #selector(durationChanged(_:)), for: .valueChanged)
        globalInputTextField.inputAccessoryView =
            toolBarWith(title:title,
                        action: #selector(DiaryRootViewController.donePressed(sender:)))
        globalInputTextField.inputView = pickerView
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            var duration:Double = 8*3600
            if let value = self.currentQuestionInfo?.value as? String {
                duration = self.timeIntervalFromString(string: value)
            }
            pickerView.countDownDuration = duration
        }
    }
    
    @objc func durationChanged(_ datePicker: UIDatePicker) {
        currentQuestionInfo = questionInfoArray[0]
        currentQuestionInfo?.value = stringFromTimeInterval(interval: datePicker.countDownDuration) as String
        tableView.reloadData()
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        let ti = NSInteger(interval)
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return NSString(format: "%.2d hours %.2d minutes", hours, minutes)
    }
    
    func timeIntervalFromString(string: String) -> TimeInterval {
        let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var numbers: [Int] = []
        for item in stringArray {
            if let number = Int(item) {
                numbers.append(number)
            }
        }
        return TimeInterval(numbers[0]*3600 + numbers[1]*60)
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        globalInputTextField.resignFirstResponder()
    }

}
