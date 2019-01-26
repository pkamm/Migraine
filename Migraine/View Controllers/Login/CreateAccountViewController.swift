//
//  CreateAccountViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/9/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit
import Firebase
import IHKeyboardAvoiding

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        KeyboardAvoiding.avoidingView = self.nameField
        KeyboardAvoiding.avoidingView = self.emailField
        KeyboardAvoiding.avoidingView = self.passwordField
        KeyboardAvoiding.avoidingView = self.createAccountButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        // TODO create nil or empty extension.  also check lengths and validitiy
        guard let email = self.emailField.text, !email.isEmpty,
              let password = self.passwordField.text, !password.isEmpty,
              let name = self.nameField.text, !name.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Enter full name, email and password", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let responseError = error{
                let alert = UIAlertController(title: "Error", message: responseError.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                let nameChangeRequest = user?.createProfileChangeRequest()
                nameChangeRequest?.displayName = name
                nameChangeRequest?.commitChanges(completion: { (error) in
                    //TODO add error handling
                    self.performSegue(withIdentifier: "WelcomeViewSegue", sender: nil)
                })
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
