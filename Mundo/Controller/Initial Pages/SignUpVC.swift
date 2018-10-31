//
//  SignUpVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var signUpBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "signUpToFirstPage", sender: nil)
    }
    

    @IBAction func signUpBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "signUpToScanner", sender: nil)
    }
}
