//
//  AddNewViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/7/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

class AddNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    

    @IBOutlet weak var newDiaryButton: UIButton!
    @IBOutlet weak var newMigraineButton: UIButton!
    
    @IBOutlet weak var migraineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newDiaryButton.layer.cornerRadius = 8;
        newMigraineButton.layer.cornerRadius = 8;
        DiaryService.sharedInstance.getDiaryEntries { (entries) in
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0;
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

class MigraineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var migraineIconImageView: UIImageView!
    @IBOutlet weak var migraineMainLabel: UILabel!
    @IBOutlet weak var migraineSecondaryLabel: UILabel!
    @IBOutlet weak var migraineDateLabel: UILabel!
    
    
}
