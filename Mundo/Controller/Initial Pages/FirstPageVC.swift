//
//  FirstPageVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/28/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class FirstPageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here we will need to check if the user is logged in
    }
    
    
    @IBAction func signUpBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "firstPageToSignUp", sender: nil)
    }
    
    @IBAction func LoginBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "firstPageToLogIn", sender: nil)
    }
    

}

