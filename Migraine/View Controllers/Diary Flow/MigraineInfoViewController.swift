//
//  QuickAddMigraineViewController.swift
//  Migraine
//
//  Created by Kamm, Peter on 10/25/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class MigraineInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SavablePage, EditDelegate {

    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "When did your migraine start?", infoKey: InfoKey.MIGRAINESTART),
        QuestionInfo(text: "When did your migraine end?", infoKey: InfoKey.MIGRAINEEND),
        QuestionInfo(text: "What was the severity of your migraine?", infoKey: InfoKey.MIGRAINESEVERITY, sliderLabels: ["Mild - able to carry on with all normal activities", "Moderate - had to take something, stopped activity", "Severe - thought about going to ER, went to bed early"])]
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let sliderTableViewCellId = "sliderTableViewCellId"
    private let dateFormatter = DateFormatter()
    
    var isQuickAddMigraine: Bool = true
    private var currentQuestionInfo: QuestionInfo?

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
        pageControl.numberOfPages = 8
        pageControl.currentPage = DiaryService.sharedInstance.hasEnteredSleepDataToday() ? 1 : 2

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        let sliderCellNib = UINib(nibName: "SliderTableViewCell", bundle: nil)
        tableView.register(sliderCellNib, forCellReuseIdentifier: self.sliderTableViewCellId)
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
        default: break
        }
        return UITableViewCell()
    }

    @objc func donePressed(sender: UIBarButtonItem) {
        globalInputTextField.resignFirstResponder()
    }
    
    func saveButtonPressed(_ sender: Any) {
        let migraineQuestion = QuestionInfo(text: "Migraine", infoKey: InfoKey.HADMIGRAINE)
        migraineQuestion.value = "Yes"
        DiaryService.sharedInstance.addQuestionInfosToPendingDiaryEntry(questionInfos: [migraineQuestion])
        DiaryService.sharedInstance.addQuestionInfosToPendingDiaryEntry(questionInfos: questionInfoArray)
        performSegue(withIdentifier: "MigraineLocationSegue", sender: nil)
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        currentQuestionInfo?.value = dateFormatter.string(from: datePicker.date)
        tableView.reloadData()
    }
}
