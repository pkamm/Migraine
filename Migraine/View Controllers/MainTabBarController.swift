//
//  MainTabBarController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/9/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "WelcomeViewSegue", sender: nil)
        }
    }

}
