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
        QuestionInfo(text: "What was the severity of your migraine?", infoKey: InfoKey.MIGRAINESEVERITY)]
    
    private let textEditTableViewCellId = "textEditTableViewCellId"
    private let sliderTableViewCellId = "sliderTableViewCellId"
    
    var isQuickAddMigraine: Bool = true
    private var currentQuestionInfo: QuestionInfo?

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
        
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

        default: break
        }
        return UITableViewCell()
    }
    
    func editButtonPressed(_ questionInfo:QuestionInfo!) {
        currentQuestionInfo = questionInfo
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if isQuickAddMigraine {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "ContinueDiarySeque", sender: nil)
        }
    }
    
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
// 
//    }

}
