//
//  MigraineLocationViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 12/26/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class MigraineLocationViewController: UIViewController, SavablePage {
    func saveButtonPressed(_ sender: Any) {
        DiaryService.sharedInstance.addCurrentListToPendingDiaryEntry(infoKey: .HEADACHELOCATIONS, list: locations)
        performSegue(withIdentifier: "SymptomsSegue", sender: self)
    }

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    private var currentQuestionInfo: QuestionInfo?
    var locations = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 8
        pageControl.currentPage = DiaryService.sharedInstance.hasEnteredSleepDataToday() ? 2 : 3
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
    }

    @IBAction func button1Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Mouth/jaw")
    }
    
    @IBAction func button2Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Behind the Eyes")
    }
    
    @IBAction func button3Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Frontal")
    }
    
    @IBAction func button4Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Temporal")
    }
    
    @IBAction func button5Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Occipital")
    }
    
    @IBAction func button6Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Base of skull")
    }
    
    @IBAction func button7Pressed(_ sender: UIButton) {
        buttonSelected(button: sender, location:"Neck")
    }
    
    func buttonSelected(button: UIButton, location: String) {
        if button.alpha == CGFloat(1.0) {
             button.alpha = CGFloat(0.1)
            locations = locations.filter{$0 != location}
        } else {
            button.alpha = CGFloat(1.0)
            locations.append(location)
        }
    }
}
