//
//  DiaryRootViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class DiaryRootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SavablePage, EditDelegate {
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How long did you sleep last night?", infoKey: InfoKey.SLEEPDURATIONMINUTES),
        QuestionInfo(text: "Quality of your sleep?", infoKey: InfoKey.SLEEPQUALITY),
        QuestionInfo(text: "How stressed are you?", infoKey: InfoKey.STRESSLEVEL),
        QuestionInfo(text: "Did you have a migraine?", infoKey: InfoKey.HADMIGRAINE)]
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!

    private var currentQuestionInfo: QuestionInfo?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(_ sender: Any) {

//        if migraineYesNoSwitch.isOn {
//            performSegue(withIdentifier: "MigraineYesSegue", sender: nil)
//        } else {
//            performSegue(withIdentifier: "MigraineNoSegue", sender: nil)
//        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: self.textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
                cell.setQuestionInfo(questionInfo)
                cell.editDelegate = self
                return cell
            }

        default: break
        }
        return UITableViewCell()
    }
    
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .SLEEPDURATIONMINUTES:
            createDurationPicker(title: "Sleep Duration")
        default:
            return;
        }
        globalInputTextField.becomeFirstResponder()
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
            let duration = self.currentQuestionInfo?.value == nil ? 8*3600 : self.timeIntervalFromString(string: (self.currentQuestionInfo?.value)!)
            pickerView.countDownDuration = duration
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let questionInfo = currentQuestionInfo {
        }
        tableView.reloadData()
    }
    
    @objc func durationChanged(_ datePicker: UIDatePicker) {
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MigraineYesSegue",
            let destination = segue.destination as? QuickAddMigraineViewController {
            destination.isQuickAddMigraine = false
        }
    }

 

}
