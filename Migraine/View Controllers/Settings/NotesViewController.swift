//
//  NotesViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 1/8/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, SavablePage {

    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var globalInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.layer.cornerRadius = 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func saveButtonPressed(_ sender: Any) {
        PatientInfoService.sharedInstance.sendNotesToFirebase(notes: notesTextView.text)
        dismiss(animated: true, completion: nil)
    }

}
