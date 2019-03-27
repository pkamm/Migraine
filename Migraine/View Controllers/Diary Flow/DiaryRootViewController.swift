//
//  DiaryRootViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class DiaryRootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SavablePage, EditDelegate {
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How long did you sleep last night?", infoKey: InfoKey.SLEEPDURATIONMINUTES),
        QuestionInfo(text: "Quality of your sleep?", infoKey: InfoKey.SLEEPQUALITY, sliderLabels: ["Sleep was awesome", "Felt rested in the morning", "Usual night's sleep", "Ok, could be better", "Felt like crap in the morning"])]
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let sliderTableViewCellId = "sliderTableViewCellId"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    
    private var currentQuestionInfo: QuestionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")

        HealthDeviceManager.sharedInstance.authorizeHealthKit { (authorized,  _error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
                HealthDeviceManager.sharedInstance.observeAllChanges()
            } else {
                print("HealthKit authorization denied!")
                print("error: ", _error)
            }
        }
        
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let sliderCellNib = UINib(nibName: "SliderTableViewCell", bundle: nil)
        tableView.register(sliderCellNib, forCellReuseIdentifier: self.sliderTableViewCellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addQuestionInfosToPendingDiaryEntry(questionInfos: questionInfoArray)
        performSegue(withIdentifier: "StressSegue", sender: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionInfo = questionInfoArray[indexPath.row]
        switch questionInfo.infoKey {
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
        default: break
        }
        return UITableViewCell()
    }
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .SLEEPDURATIONMINUTES:
            createDurationPicker(title: "Sleep Duration")
            globalInputTextField.becomeFirstResponder()
            break
        default:
            return;
        }
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
 

}
