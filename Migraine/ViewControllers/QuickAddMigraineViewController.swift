//
//  QuickAddMigraineViewController.swift
//  Migraine
//
//  Created by Kamm, Peter on 10/25/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit

class QuickAddMigraineViewController: UIViewController {

    var isQuickAddMigraine: Bool = true
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nextButtonTitle = isQuickAddMigraine ? "Save" : "Next"
        continueButton.setTitle(nextButtonTitle, for: .normal)
        if isQuickAddMigraine { addCancelButton() }
    }
    
    func addCancelButton() {
        let backbutton = UIButton(type: .custom)
        backbutton.setTitle("Cancel", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action:#selector(self.cancelButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
