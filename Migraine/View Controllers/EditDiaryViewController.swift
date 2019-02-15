//
//  EditDiaryViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 2/15/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit

class EditDiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SavablePage, EditDelegate {
    
    var editableDiaryEntry:DiaryEntry?
    
    private var questionInfoArray:[QuestionInfo] = []
    
    private var currentQuestionInfo: QuestionInfo?

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var globalInputTextField: UITextField!
    
    private let dateFormatter = DateFormatter()

    private let sliderTableViewCellId = "sliderTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"
    private let textEditTableViewCellId = "textEditTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Save Changes")
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        let sliderCellNib = UINib(nibName: "SliderTableViewCell", bundle: nil)
        tableView.register(sliderCellNib, forCellReuseIdentifier: self.sliderTableViewCellId)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        addMigraineEndDateIfNeeded()
        populateQuestionInfoText()
    }
    
    private func addMigraineEndDateIfNeeded(){
        var isMigraine = false
        if let entry = editableDiaryEntry {
            for questionInfo in entry.questionInfos {
                if questionInfo.infoKey == .MIGRAINESTART {
                    isMigraine = true
                }
            }
            if isMigraine {
                var hasEndDate = false
                for questionInfo in entry.questionInfos {
                    if questionInfo.infoKey == .MIGRAINEEND {
                        hasEndDate = true
                    }
                }
                if !hasEndDate {
                    let questionInfo = DiaryService.sharedInstance.questionInfoFor(infoKey: .MIGRAINEEND)
                    questionInfoArray.append(questionInfo)
                }
            }
        }
    }
    
    private func populateQuestionInfoText() {
        if let entry = editableDiaryEntry {
            for questionInfo in entry.questionInfos {
                let newQuestionInfo = DiaryService.sharedInstance.questionInfoFor(infoKey: questionInfo.infoKey)
                newQuestionInfo.value = questionInfo.value
                questionInfoArray.append(newQuestionInfo)
            }
        }
    }
    
    func saveButtonPressed(_ sender: Any) {
        if let entry = editableDiaryEntry{
            DiaryService.sharedInstance.submit(questionInfos: questionInfoArray, date: entry.date) {
                self.navigationController?.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: Notification.Name("ReloadDiaryDataNotification"), object: nil)
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let questionInfos = editableDiaryEntry?.questionInfos {
            return questionInfos.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let questionInfo = questionInfoArray[indexPath.row]
        switch questionInfo.infoKey {
        case .MIGRAINESTART, .MIGRAINEEND:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
            break
        case .MIGRAINESEVERITY:
            if let cell = tableView.dequeueReusableCell(withIdentifier: sliderTableViewCellId, for: indexPath) as? SliderTableViewCell {
                cell.setQuestionInfo(questionInfo, scale: 2)
                cell.editDelegate = self
                return cell
            }
            break
        case .STRESSLEVEL:
            if let cell = tableView.dequeueReusableCell(withIdentifier: sliderTableViewCellId, for: indexPath) as? SliderTableViewCell {
                cell.setQuestionInfo(questionInfo, scale: 4)
                cell.editDelegate = self
                return cell
            }
            break
        case .HADMIGRAINE:
            if let cell = tableView.dequeueReusableCell(withIdentifier: segmentedSelectTableViewCellId, for: indexPath) as? SegmentedSelectTableViewCell {
                cell.setSegmentedValues(["Yes", "No"])
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
        case .SLEEPDURATIONMINUTES:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
            break
        case .SLEEPQUALITY:
            if let cell = tableView.dequeueReusableCell(withIdentifier: sliderTableViewCellId, for: indexPath) as? SliderTableViewCell {
                cell.setQuestionInfo(questionInfo, scale: 4)
                cell.editDelegate = self
                return cell
            }
            break
        case .TRIGGERSTODAY:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
            break
        case .SYMPTOMSTODAY:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
            break
        case .HELPMIGRAINETODAY:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
        case .HEADACHELOCATIONS:
            if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }
            break
            
        default: break
        }
        
        return UITableViewCell()
    }
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .MIGRAINESTART:
            createDatePicker(title: "Migraine Start")
            break
        case .MIGRAINEEND:
            createDatePicker(title: "Migraine Start")
            break
        case .SLEEPDURATIONMINUTES:
            createDurationPicker(title: "Sleep Duration")
            globalInputTextField.becomeFirstResponder()
            break
//        case .HADMIGRAINE:
//            if let value = questionInfo.value as? String {
//                isMigraine = (value == "Yes")
//            }
//            break
        default:
            return;
        }
        globalInputTextField.becomeFirstResponder()
    }
    
    func createDatePicker(title:String) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .dateAndTime
        pickerView.maximumDate = Date()
        pickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        globalInputTextField.inputAccessoryView =
            toolBarWith(title:title,
                        action: #selector(GeneralInfoViewController.donePressed(sender:)))
        globalInputTextField.inputView = pickerView
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        currentQuestionInfo?.value = dateFormatter.string(from: datePicker.date)
        tableView.reloadData()
    }
    
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
    
    // MARK: - Navigation
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
}
