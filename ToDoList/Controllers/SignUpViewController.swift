//
//  SignUpViewController.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var labelsStackView: UIStackView!
    var validationStackView: UIStackView = UIStackView()
    var emptyValidationLabel: UILabel?
    var emailValidadtionLabel: UILabel?
    var emailAvailabilityValidationLabel: UILabel?
    var passwordValidationLabel: UILabel?
    
    let toDoListDataStore: ToDoListDataStore = ToDoListDataStore()
    var users: [User]?
    
    var firstNameToSegue: String?
    var lastNameToSegue: String?
    var emailToSegue: String?
    
    let dispatchGroupToGetUsers: DispatchGroup = DispatchGroup()
    let dispatchGroupToCheckEmailAvailability: DispatchGroup = DispatchGroup()
    var isEmailAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateInputs(firstName: firstName, lastName: lastName, email: email, password: password, confirmPassword: confirmPassword) else {
            return
        }
        signUpUser(firstName: firstName, lastName: lastName, email: email, password: password)
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    // In this function, the app checks if the user email is available.
    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        self.isEmailAvailable = true
        let email = emailTextField.text
        toDoListDataStore.getUsers(userId: nil) { (usersResult) in
            switch usersResult {
            case let .success(response):
                self.users = response
                for user in self.users! {
                    let compareResult = user.email.caseInsensitiveCompare(email!)
                    if compareResult == ComparisonResult.orderedSame {
                        self.isEmailAvailable = false
                        let alert = UIAlertController(title: "Email Taken", message: "The email entered is already taken. Please enter a different email", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.emailTextField.text = ""
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    
    private func validateInputs(firstName: String, lastName: String, email: String, password: String, confirmPassword: String) -> Bool {
        emptyValidationLabel?.removeFromSuperview()
        emailValidadtionLabel?.removeFromSuperview()
        passwordValidationLabel?.removeFromSuperview()
        validationStackView.removeFromSuperview()
        
        var fieldsFilled = true
        var isGoodEmail = true
        var isGoodPassword = true
        
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            emptyValidationLabel = UILabel()
            emptyValidationLabel!.text = "Fill in all the fields."
            emptyValidationLabel!.textColor = UIColor.red
            validationStackView.addArrangedSubview(emptyValidationLabel!)
            fieldsFilled = false
        }
        
        if !isValidEmail(email: email) {
            emailValidadtionLabel = UILabel()
            emailValidadtionLabel!.text = "Enter a valid email."
            emailValidadtionLabel!.textColor = UIColor.red
            validationStackView.addArrangedSubview(emailValidadtionLabel!)
            isGoodEmail = false
        }
        
        if !passwordMatches(password: password, confirmPassword: confirmPassword) {
            passwordValidationLabel = UILabel()
            passwordValidationLabel!.text = "Password and confirm password don't match."
            passwordValidationLabel!.textColor = UIColor.red
            validationStackView.addArrangedSubview(passwordValidationLabel!)
            isGoodPassword = false
        }
        
        guard fieldsFilled && isGoodEmail && isGoodPassword && isEmailAvailable else {
            validationStackView.translatesAutoresizingMaskIntoConstraints = false
            validationStackView.axis = .vertical
            self.view.addSubview(validationStackView)
            validationStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            validationStackView.topAnchor.constraint(equalTo: self.labelsStackView.bottomAnchor, constant: 10).isActive = true
            return false
        }
        return true
    }
    
    private func signUpUser(firstName: String, lastName: String, email: String, password: String) {
        let getAllUsersGroup = DispatchGroup()
        getAllUsersGroup.enter()
        toDoListDataStore.getUsers(userId: nil) { (usersResult) in
            switch usersResult {
            case let .success(response):
                self.users = response
            case let .failure(error):
                print(error)
            }
            getAllUsersGroup.leave()
        }
        getAllUsersGroup.notify(queue: .main, execute: {
            var idCandidate = arc4random_uniform(1000) + 1 // represents the candidate of the userId
            var uniqueCounter = 0 // represents the number of IDs from the DB that are different from randomNum
            let max = self.users!.count
            
            while uniqueCounter != max {
                for i in 0...max {
                    if i == max && uniqueCounter != max {
                        // recreates an ID
                        uniqueCounter = 0 // reset the counter to 0
                        idCandidate = arc4random_uniform(1000) + 1
                        break
                    }
                    if i != max {
                        if self.users![i].id != idCandidate.description {
                            uniqueCounter += 1
                        }
                    }
                }
            }
            
            let userToInsert = User(id: idCandidate.description, firstName: firstName, lastName: lastName, email: email, password: password)
            self.toDoListDataStore.postPutUser(method: "POST", user: userToInsert)
            self.firstNameToSegue = firstName
            self.lastNameToSegue = lastName
            self.emailToSegue = email
            self.performSegue(withIdentifier: "goToSignupConfirmation", sender: self)
        })
    }
    
    // private function to detect if the email is valid.
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func passwordMatches(password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSignupConfirmation" {
            let signUpConfirmationviewController = segue.destination as! SignUpConfirmationViewController
            signUpConfirmationviewController.firstName = firstNameToSegue!
            signUpConfirmationviewController.lastName = lastNameToSegue!
            signUpConfirmationviewController.email = emailToSegue!
        }
    }
    
    
    
}
