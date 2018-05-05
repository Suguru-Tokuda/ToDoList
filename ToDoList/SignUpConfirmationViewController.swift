//
//  SignUpConfirmationViewController.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class SignUpConfirmationViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var firstName: String?
    var lastName: String?
    var email: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = firstName!
        lastNameLabel.text = lastName!
        emailLabel.text = email!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
