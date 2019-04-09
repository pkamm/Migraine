//
//  HeadacheDetailsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 2/15/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit

class HeadacheDetailsViewController: UIViewController, SavablePage, EditDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    var isOnboarding = false
    @IBOutlet weak var saveButtonHeight: NSLayoutConstraint!
    
    private let dateFormatter = DateFormatter()
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How long does your typical headache last?", infoKey: .HEADACHEDURATION),
        QuestionInfo(text: "What side is your headache typically on?", infoKey: .HEADACHESIDE),
        QuestionInfo(text: "Do you typically get aura?", infoKey: .GETAURA),
        QuestionInfo(text: "Describe your aura", infoKey: .AURANOTES)]
    
    private let headacheSideOptions = ["On one side", "On both sides", "Alternates sides"]
    private let typicallyGetAuroOptions = ["Yes", "No"]

    private var currentQuestionInfo: QuestionInfo?
    private var isAuraSelected: Bool = false
    
    enum PickerViewTag: Int {
        case PickerHeadacheDuration
        case PickerHeadacheSide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        if isOnboarding {
            saveButtonHeight.constant = 110
        }
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
                            (value == "Yes") && (userInfoKey == .GETAURA) {
                            isAuraSelected = true
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
        }
        PatientInfoService.sharedInstance.saveUser(infoDictionary: userInfoDictionary as [String : AnyObject])
        if isOnboarding{
            performSegue(withIdentifier: "OnboardingNotificationSegue", sender: self)
        } else {
            showSavedAlert("Info Saved!")
        }
    }
    
    // Mark TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAuraSelected {
            return self.questionInfoArray.count
        } else {
            return self.questionInfoArray.count - 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionInfo = questionInfoArray[indexPath.row]
        var cell = UITableViewCell()
        switch questionInfo.infoKey {
        case .HEADACHEDURATION, .HEADACHESIDE, .AURANOTES:
            cell = tableView.dequeueReusableCell(withIdentifier: self.textEditTableViewCellId, for: indexPath) as! TextEditTableViewCell
            break

        case .GETAURA:
            if let theCell = tableView.dequeueReusableCell(withIdentifier: self.segmentedSelectTableViewCellId, for: indexPath) as? SegmentedSelectTableViewCell {
                let segmentValues = self.typicallyGetAuroOptions
                theCell.setSegmentedValues(segmentValues)
                cell = theCell
            }
            break

        default: break
        }
        if let theCell = cell as? QuestionInfoTableViewCell{
            theCell.setQuestionInfo(questionInfo)
            theCell.setEditDelegate(self)
            return cell
        }
        return UITableViewCell()
    }
    
    
    // picker
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .AURANOTES:
            showTextFieldAlert()
            return
        case .GETAURA:
            if let value = self.currentQuestionInfo?.value as? String {
                isAuraSelected = (value == "Yes")
            }
            tableView.reloadData()
            return
        case .HEADACHEDURATION:
            createDurationPicker(title: "Sleep Duration")
            break
        case .HEADACHESIDE:
            createPicker(title: "Headache Side")
            break
        default:
            return;
        }
        tableView.reloadData()
        globalInputTextField.becomeFirstResponder()
    }
    
    func showTextFieldAlert(){
        let alert = UIAlertController(title: "Aura Notes", message: "\n\n\n", preferredStyle: .alert)
        alert.view.autoresizesSubviews = true
        
        let textView = UITextView(frame: CGRect.zero)
        textView.enablesReturnKeyAutomatically = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        if let auraText = currentQuestionInfo?.value as? String {
            textView.text = auraText
        }
        
        let leadConstraint = NSLayoutConstraint(item: alert.view, attribute: .leading, relatedBy: .equal, toItem: textView, attribute: .leading, multiplier: 1.0, constant: -8.0)
        let trailConstraint = NSLayoutConstraint(item: alert.view, attribute: .trailing, relatedBy: .equal, toItem: textView, attribute: .trailing, multiplier: 1.0, constant: 8.0)
        
        let topConstraint = NSLayoutConstraint(item: alert.view, attribute: .top, relatedBy: .equal, toItem: textView, attribute: .top, multiplier: 1.0, constant: -64.0)
        let bottomConstraint = NSLayoutConstraint(item: alert.view, attribute: .bottom, relatedBy: .equal, toItem: textView, attribute: .bottom, multiplier: 1.0, constant: 64.0)
        alert.view.addSubview(textView)
        NSLayoutConstraint.activate([leadConstraint, trailConstraint, topConstraint, bottomConstraint])
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.currentQuestionInfo?.value = textView.text
            self.tableView.reloadData()
            textView.resignFirstResponder()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func createPicker(title:String) {
        let pickerView = UIPickerView()
        globalInputTextField.inputAccessoryView =
            addToolbarTo(picker: pickerView,
                         title:title,
                         action: #selector(GeneralInfoViewController.donePressed(sender:)))
        globalInputTextField.inputView = pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return headacheSideOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return headacheSideOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentQuestionInfo?.value = headacheSideOptions[row]
        tableView.reloadData()
    }
    
    func createDurationPicker(title:String) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .countDownTimer
        pickerView.minuteInterval = 15
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
    
    func addToolbarTo(picker: UIPickerView, title: String!, action: Selector?) -> UIToolbar {
        let toolBar = self.toolBarWith(title: title, action: action)
        picker.dataSource = self
        picker.delegate = self
        return toolBar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingVC = segue.destination as? NotificationsViewController {
            onboardingVC.isOnboarding = true
        }
    }

}
