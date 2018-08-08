//
//  DiaryRootViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 10/26/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class DiaryRootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SavablePage {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    private let questionInfoArray:[QuestionInfo] = [
        QuestionInfo(text: "How long did you sleep last night?", infoKey: InfoKey.SLEEPDURATIONMINUTES),
        QuestionInfo(text: "Quality of your sleep?", infoKey: InfoKey.SLEEPQUALITY),
        QuestionInfo(text: "How stressed are you?", infoKey: InfoKey.STRESSLEVEL),
        QuestionInfo(text: "Did you have a migraine?", infoKey: InfoKey.HADMIGRAINE)]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MigraineYesSegue",
            let destination = segue.destination as? QuickAddMigraineViewController {
            destination.isQuickAddMigraine = false
        }
    }
 

}
