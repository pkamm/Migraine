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
        collapsed = true
    }
}

class TriggersViewController: UIViewController, SavablePage, UIAlertViewDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {

    // for triggers
    let sectionA = Section(title: "Everyday Stressors", objects: ["Emotional Stress", "Hunger", "Dehydration", "Gaps in Between Meals", "Sexual Activity", "Infections", "Too Much Sleep", "Lack of Sleep", "Tiring Activity", "Exercise"])
    let sectionB = Section(title: "Foods", objects: ["MSG", "Onions", "Citrus/Bananas", "Cheese", "Chocolate", "Food With Nitrates e.g. Cold Cuts of Meat", "Processed Foods", "Gluten Containing Foods e.g. Wheat and Barley", "Tyramine Containing Foods", "Dyes in Food", "Artificial Sweetners", "Aspartame - Equal", "Saccharin - Sweet n Low", "Stevia", "Sucralose - Chlorinated Sucrose"])
    let sectionC = Section(title: "Hormonal", objects: ["Menstruation", "Birth Control Pill"])
    let sectionD = Section(title: "Sensory Overload", objects: ["Light", "Noise", "Motion", "Perfumes"])
    let sectionE = Section(title: "Weather", objects: ["High Barometeric Pressure", "High Humidity", "High Temperature", "Wind", "Change in Temperature", "Cold Temperature", "Lightning", "Drop in Barometric Pressure", "Flying"])
    let sectionF = Section(title: "Pollution", objects: ["Smoke"])
    let sectionG = Section(title: "Recreational Substances", objects: ["Cigarette smoking", "Alcohol", "Cocaine", "Marijuana", "Heroin", "Ritalin", "Amphetamine"])
    let sectionH = Section(title: "Other", objects: ["Headache Medication (Medication Rebound)"])
    
    var triggerSections:[Section] = []
    var selectedTriggers = [String]()
    var isOnboarding = false

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let addElementTableViewCellId = "AddElementViewControllerId"
    private let selectableTableViewCellId = "SelectableTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.saveDelagate = self
        if isOnboarding {
            saveButtonFooter.setTitle(title: "Next")
        } else {
            pageControl.isHidden = true
            saveButtonFooter.setTitle(title: "Save")
        }
        let allElementNib = UINib(nibName: "AddElementTableViewCell", bundle: nil)
        tableView.register(allElementNib, forCellReuseIdentifier: addElementTableViewCellId)
        let selectableNib = UINib(nibName: "SelectableTableViewCell", bundle: nil)
        tableView.register(selectableNib, forCellReuseIdentifier: selectableTableViewCellId)
        triggerSections = [sectionA, sectionB, sectionC, sectionD, sectionE, sectionF, sectionG, sectionH];
        
        PatientInfoService.sharedInstance.getMedicalConditions { (savedConditions) in
            if let serverSavedConditions = savedConditions,
                let serverConditions = serverSavedConditions["TRIGGERS"] as? [String]{
                self.selectedTriggers = serverConditions
                for trigger in self.selectedTriggers {
                    var isUserAdded = true
                    for triggerSection in self.triggerSections {
                        if triggerSection.items.contains(trigger) {
                            isUserAdded = false
                            break
                        }
                    }
                    if( isUserAdded ){
                        self.triggerSections[7].items.append(trigger)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveButtonPressed(_ sender: Any) {
        let triggerDictionary = ["TRIGGERS": selectedTriggers]
        PatientInfoService.sharedInstance.saveUser(infoDictionary: triggerDictionary as [String : AnyObject])
        if isOnboarding {
            performSegue(withIdentifier: "OnboardingHelpersSegue", sender: self)
        } else {
            showSavedAlert("Triggers Saved!")
        }

    }
    
    
    // Mark TableViewDelegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let addNewColumn = (section == 7) ? 1 : 0;
        return triggerSections[section].collapsed ? 0 : triggerSections[section].items.count + addNewColumn
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
        if indexPath.section == 7, indexPath.row == triggerSections[7].items.count, let cell = tableView.dequeueReusableCell(withIdentifier: addElementTableViewCellId, for: indexPath) as? AddElementTableViewCell {
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: selectableTableViewCellId, for: indexPath) as? SelectableTableViewCell {
                let triggerString = triggerSections[indexPath.section].items[indexPath.row];
                cell.addTitleText(triggerString)
                if( self.selectedTriggers.contains(triggerString) ){
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(cell.isSelected, animated: false);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if( indexPath.section == 7 && indexPath.row == triggerSections[7].items.count ){
            showAddNewTriggerAlert()
        } else {
            let trigger = triggerSections[indexPath.section].items[indexPath.row]
            selectedTriggers.append(trigger)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let trigger = triggerSections[indexPath.section].items[indexPath.row]
        if selectedTriggers.contains(trigger) {
            selectedTriggers = selectedTriggers.filter(){$0 != trigger}
        }
    }
    
    func showAddNewTriggerAlert() {
        let alertBox = UIAlertController(title: "Trigger", message: nil, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = alertBox.textFields![0] as UITextField
            self.addNewTrigger(textField.text)
        }))
        alertBox.addTextField { (textField) in
            textField.placeholder = "Trigger"
        }
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alertBox, animated: true, completion: nil);
    }
    
    func addNewTrigger(_ newTrigger:String!) {
        if newTrigger != "" {
            if !triggerSections[7].items.contains(newTrigger) {
                triggerSections[7].items.append(newTrigger)
                selectedTriggers.append(newTrigger)
                tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "The item you tried to add is already in the list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Triggers", message: "Trigger are foods, actions, or other stimuli that tend to initiate migraines for you.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingVC = segue.destination as? HelpersViewController {
            onboardingVC.isOnboarding = true
        }
    }

}
