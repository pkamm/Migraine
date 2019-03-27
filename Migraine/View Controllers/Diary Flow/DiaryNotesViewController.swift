//
//  DiaryNotesViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 3/27/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit

class DiaryNotesViewController: UIViewController, SavablePage, UITextViewDelegate {

    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!
    @IBOutlet weak var globalInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.layer.cornerRadius = 5
        saveButtonFooter.saveDelagate = self
        saveButtonFooter.setTitle(title: "Next")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func saveButtonPressed(_ sender: Any) {
        if let notesText = notesTextView.text,
            notesText != "" {
            let notesQuestionInfo = QuestionInfo(value: notesText, infoKey: .DIARYNOTES)
            DiaryService.sharedInstance.addQuestionInfosToPendingDiaryEntry(questionInfos: [notesQuestionInfo])
            DiaryService.sharedInstance.submitPendingDiaryEntry {
                self.performSegue(withIdentifier: "SuccessSegue", sender: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }

}
