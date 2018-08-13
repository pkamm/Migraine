//
//  TriggersViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 4/24/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

struct Section {
    
    var heading : String
    var items : [String]
    var collapsed : Bool
    
    init(title: String, objects : [String]) {
        heading = title
        items = objects
        collapsed = false
    }
}

class TriggersViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    func saveButtonPressed(_ sender: Any) {
        
    }
    

    // for triggers
    let sectionA = Section(title: "Everyday Stressors", objects: ["Emotional Stress", "Hunger", "Dehydration", "Gaps in Between Meals", "Sexual Activity", "Infections", "Too Much Sleep", "Lack of Sleep", "Tiring Activity", "Exercise"])
    let sectionB = Section(title: "Foods", objects: ["MSG", "Onions", "Citrus/Bananas", "Cheese", "Chocolate", "Nitrites", "Processed Foods", "Gluten", "Tyramine", "Dyes in Food", "Artificial Sweetners", "Aspartame", "Saccharin", "Sucralose - Chlorinated Sucrose"])
    let sectionC = Section(title: "Hormonal", objects: ["Menstruation", "Birth Control Pill"])
    let sectionD = Section(title: "Sensory Overload", objects: ["Light", "Noise", "Motion", "Perfumes"])
    let sectionE = Section(title: "Weather", objects: ["High Barometeric Pressure", "High Humidity", "High Temperature", "Wind", "Change in Temperature", "Cold Temperature", "Lightning", "Drop in Barometric Pressure", "Flying"])
    let sectionF = Section(title: "Pollution", objects: ["Smoke"])
    let sectionG = Section(title: "Recreational Substances", objects: ["Cigarette smoking", "Alcohol", "Cocaine", "Marijuana", "Heroin", "Ritalin", "Amphetamine"])
    let sectionH = Section(title: "Other", objects: ["Headache Medication (Medication Rebound)"])
    
    var triggerSections:[Section] = []
    
    var selectedTriggers = [String]()
    
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        triggerSections = [sectionA, sectionB, sectionC, sectionD, sectionE, sectionF, sectionG, sectionH];

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Mark TableViewDelegate Methods

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triggerSections[section].collapsed ? 0 : triggerSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return triggerSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TitleHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height:60))
        headerView.setTitle(triggerSections[section].heading)
        headerView.tag = section
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(sectionHeaderTapped))
        headerView.addGestureRecognizer(headerTapped)
        return headerView
    }
    
    @objc func sectionHeaderTapped(_ recognizer: UITapGestureRecognizer) {
        if let section = recognizer.view?.tag{
            triggerSections[section].collapsed = !triggerSections[section].collapsed
            let range = NSMakeRange(section, 1)
            let sectionToReload = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sectionToReload as IndexSet, with:UITableViewRowAnimation.fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.row == symptoms.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
//            return cell
//        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                cell.addTitleText(triggerSections[indexPath.section].items[indexPath.row])
                return cell
//            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(cell.isSelected, animated: false);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == symptoms.count {
//            showAddNewSymptomAlert()
//        } else {
            let trigger = triggerSections[indexPath.section].items[indexPath.row]
            selectedTriggers.append(trigger)
//        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let trigger = triggerSections[indexPath.section].items[indexPath.row]
        if selectedTriggers.contains(trigger) {
            selectedTriggers = selectedTriggers.filter(){$0 != trigger}
        }
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
