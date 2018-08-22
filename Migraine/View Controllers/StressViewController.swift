//
//  StressViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/22/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class StressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SavablePage, EditDelegate {

    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How stressed are you?", infoKey: InfoKey.STRESSLEVEL),
        QuestionInfo(text: "Did you have a migraine?", infoKey: InfoKey.HADMIGRAINE)]
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    private var currentQuestionInfo: QuestionInfo?
    private var isMigraine: Bool = false
    
    private let sliderTableViewCellId = "sliderTableViewCellId"
    private let segmentedSelectTableViewCellId = "segmentedSelectTableViewCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
        let segmentCellNib = UINib(nibName: "SegmentedSelectTableViewCell", bundle: nil)
        tableView.register(segmentCellNib, forCellReuseIdentifier: self.segmentedSelectTableViewCellId)
        let sliderCellNib = UINib(nibName: "SliderTableViewCell", bundle: nil)
        tableView.register(sliderCellNib, forCellReuseIdentifier: self.sliderTableViewCellId)
    }

    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addQuestionInfosToPendingDiaryEntry(questionInfos: questionInfoArray)
        if isMigraine {
            performSegue(withIdentifier: "MigraineYesSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "MigraineNoSegue", sender: nil)
        }
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
        case .STRESSLEVEL:
            if let cell = tableView.dequeueReusableCell(withIdentifier: sliderTableViewCellId, for: indexPath) as? SliderTableViewCell {
                cell.setQuestionInfo(questionInfo, scale: 10, labels: nil)
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
        default: break
        }
        return UITableViewCell()
    }
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
        switch questionInfo.infoKey {
        case .HADMIGRAINE:
            isMigraine = (questionInfo.value == "Yes")
        default:
            return;
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MigraineYesSegue",
            let destination = segue.destination as? MigraineInfoViewController {
            destination.isQuickAddMigraine = false
        }
    }


}
