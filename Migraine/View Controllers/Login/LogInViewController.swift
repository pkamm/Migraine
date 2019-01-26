//
//  LogInViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/9/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class LogInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        // TODO create nil or empty extension.  also check lengths and validitiy
        guard let email = self.emailField.text, !email.isEmpty,
            let password = self.passwordField.text, !password.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Enter email and password", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let responseError = error{
                let alert = UIAlertController(title: "Error", message: responseError.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "OnboardingSegueId", sender: nil)
            }
        }
        
    }

    
    @IBOutlet weak var temp: UIButton!
    @IBAction func temp(_ sender: Any) {
        Auth.auth().signIn(withEmail: "sprizzla@gmail.com", password: "oakley9") { (user, error) in
            if let responseError = error{
                let alert = UIAlertController(title: "Error", message: responseError.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "OnboardingSegueId", sender: nil)
            }
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
