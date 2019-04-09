//
//  NotificationsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/28/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SavablePage, EditDelegate  {

    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "When would you like your first notification?", infoKey: InfoKey.MORNINGNOTIFICATION),
        QuestionInfo(text: "When would you like your second notification?", infoKey: InfoKey.EVENINGNOTIFICATION)]
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalInputTextField: UITextField!
    @IBOutlet weak var clearNotificationButton: UIButton!
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private var currentQuestionInfo: QuestionInfo?
    private let dateFormatter = DateFormatter()
    var isOnboarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.timeStyle = .short
        let editCellNib = UINib(nibName: "TextEditTableViewCell", bundle: nil)
        tableView.register(editCellNib, forCellReuseIdentifier: self.textEditTableViewCellId)
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Save")
        clearNotificationButton.layer.cornerRadius = 4
        clearNotificationButton.layer.borderWidth = 1
        clearNotificationButton.layer.borderColor = UIColor.minorTextColor().cgColor
        self.getPendingRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionInfo = questionInfoArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: textEditTableViewCellId, for: indexPath) as? TextEditTableViewCell {
            cell.setQuestionInfo(questionInfo)
            if questionInfo.value == nil {
                cell.addValueText("Never")
            }
            cell.editDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        globalInputTextField.resignFirstResponder()
    }
    
    func saveButtonPressed(_ sender: Any) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {
                let center = UNUserNotificationCenter.current()
                // Request permission to display alerts and play sounds.
                center.requestAuthorization(options: [.alert, .sound])
                { (granted, error) in
                    self.scheduleNotifications()
                }
                return
            }
            self.scheduleNotifications()
        }
    }
    
    func getPendingRequests() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    for questionInfo in self.questionInfoArray {
                        if questionInfo.infoKey.rawValue == request.identifier {
                            questionInfo.value = self.dateFormatter.string(from: trigger.nextTriggerDate()!)
                        }
                    }
                }
            }
            if self.isOnboarding {
                self.questionInfoArray[0].value = self.dateStringAtTime(hours: 9, minutes: 30)
                self.questionInfoArray[1].value = self.dateStringAtTime(hours: 19, minutes: 30)
            }
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    func dateStringAtTime(hours: Int, minutes: Int) -> String {
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        let userCalendar = Calendar.current
        let someDateTime = userCalendar.date(from: dateComponents)
        return self.dateFormatter.string(from: someDateTime!)
    }
    
    func scheduleNotifications(){
        self.removeExistingNotifications()
        for questionInfo in self.questionInfoArray {
            self.scheduleNotification(for: questionInfo)
        }
        OperationQueue.main.addOperation {
            if self.isOnboarding{
                self.showOnboardingComplete()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func showOnboardingComplete(){
        let titleText = "\n\n\n" + "All Info Saved!"
        let alert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.dismiss(animated: true, completion:   nil)
        })
        alert.addAction(action)
        alert.addCheckMark()
        present(alert, animated: true, completion: nil)
    }
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        createDatePicker(title: "Notification Time")
        globalInputTextField.becomeFirstResponder()
    }
    
    func createDatePicker(title:String) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .time
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
    
    func scheduleNotification(for questionInfo:QuestionInfo) {
        guard let dateString = questionInfo.value as? String,
            let date = dateFormatter.date(from: dateString) else { return }
        let content = UNMutableNotificationContent()
        content.title = "Let's Talk"
        content.body = "Regards, Your Migraine Diary"
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        var dateInfo = DateComponents()
        dateInfo.hour = comp.hour
        dateInfo.minute = comp.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
        let request = UNNotificationRequest(identifier: questionInfo.infoKey.rawValue, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    @IBAction func clearNotificationsButtonPressed(_ sender: Any) {
        self.questionInfoArray[0].value = nil
        self.questionInfoArray[1].value = nil
        tableView.reloadData()
    }
    
    func removeExistingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
