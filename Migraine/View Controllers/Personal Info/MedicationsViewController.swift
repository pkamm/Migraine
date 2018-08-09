//
//  MedicationsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 5/1/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class MedicationsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addMedicationButton: UIButton!
    @IBOutlet weak var medicationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMedicationButton.layer.cornerRadius = 8
        medicationTextField.layer.cornerRadius = 8
        medicationTextField.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
