//
//  SignInViewController.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var validationTextField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        validationTextField.text = ""
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    private func validateInputVals(email: String, password: String) -> Bool {
        if email.isEmpty || password.isEmpty {
            validationTextField.text = "Fill the fields to sign in."
            return false
        }
        
        if !isValidEmail(testStr: email) {
            validationTextField.text = "Please put valid email."
            return false
        }
        return true
    }
    
    // private function to detect if the email is valid.
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}
