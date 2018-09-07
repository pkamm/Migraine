//
//  CreateAccountViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 11/9/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var dismissGesture = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.dismissKeyboard(_:)))
    var keyboardHeight: CGFloat = 0
    var keyboardIsShown: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissGesture = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.dismissKeyboard(_:)))
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Keyboard stuff.
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(CreateAccountViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(CreateAccountViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard !keyboardIsShown else{
            return
        }
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        if(keyboardSize.height != 0){
            keyboardHeight = keyboardSize.height
        }
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as! CGFloat
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y - self.keyboardHeight), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: {(success) in
            self.view.addGestureRecognizer(self.dismissGesture)
            self.keyboardIsShown = true
        })
    }
    
    @objc func dismissKeyboard(_ sender:Any) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        nameField.resignFirstResponder()
    }

    
    @objc func keyboardWillHide(_ notification: NSNotification) {

        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y + self.keyboardHeight), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion:{ (success) in
            self.view.removeGestureRecognizer(self.dismissGesture)
            self.keyboardIsShown = false
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
