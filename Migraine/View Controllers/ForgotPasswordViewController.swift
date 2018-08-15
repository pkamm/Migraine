//
//  ForgotPasswordViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/15/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit
import Firebase


class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var forgotPasswordNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextBox.layer.cornerRadius = 8
        emailTextBox.clipsToBounds = true
        emailTextBox.backgroundColor = UIColor.lightText
        resetPasswordButton.layer.cornerRadius = 8
        navigationController?.setNavigationBarHidden(false, animated: false)
        forgotPasswordNavigationItem.setHidesBackButton(true, animated: false)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        if let email = emailTextBox.text, email != "" {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                let alert = UIAlertController(title: "Email Sent", message: "An email with instructions has been sent to \(email)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Please enter an email address", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
