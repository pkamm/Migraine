//
//  DiarySuccessViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/22/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class DiarySuccessViewController: UIViewController, SavablePage {

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.setTitle(title: "Close")
        saveButtonFooter.saveDelagate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func saveButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion:nil);
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
