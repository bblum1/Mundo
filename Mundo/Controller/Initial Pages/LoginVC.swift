//
//  LoginVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var signInBttn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "logInToFirstPage", sender: nil)
    }
    
    @IBAction func signInBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "logInToScanner", sender: nil)
    }
    
}
