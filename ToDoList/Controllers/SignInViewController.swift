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
    
    let toDoListDataStore: ToDoListDataStore = ToDoListDataStore()
    var appDelegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        validationTextField.text = ""
        let email = emailTextField.text
        let password = passwordTextField.text
        
        guard validateInputVals(email: email!, password: password!) else {
            return
        }
        
        signIn(email: email!, password: password!)
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
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func signIn(email: String, password: String) {
        var users: [User]?
        toDoListDataStore.getUsers(userId: nil) { (usersResult) in
            switch usersResult {
            case let .success(response):
                users = response
                for user in users! {
                    let ignoreCaseComparison = email.caseInsensitiveCompare(user.email)
                    let emailMatch = ignoreCaseComparison == ComparisonResult.orderedSame
                    let passwordFromDB = user.password
                    if  emailMatch && password == passwordFromDB {
                        self.appDelegate!.user = user
                        self.appDelegate!.isLoggedIn = true
                        self.performSegue(withIdentifier: "goToToDoLists", sender: self)
                    }
                }
                // login failure
                let alert = UIAlertController(title: "Login Fail", message: "The email and password don't match. Try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            case let .failure(error):
                print(error)
            }
        }
        
    }

}
