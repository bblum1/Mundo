//
//  FirstPageVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/28/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class FirstPageVC: UIViewController {
    
    var activitySpinnerClass = ActivitySpinnerClass()
    var userService = UserService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activitySpinnerClass.startSpinner(viewcontroller: self)
        
        if let cachedEmail = userService.userEmail {
            print("SAVED USER EMAIL::::\(cachedEmail)")
            activitySpinnerClass.stopSpinner()
            print("PERFORMING SEGUE")
            performSegue(withIdentifier: "firstPageToScanner", sender: nil)
        }
        print("No user login yet")
        // Else user has not logged in for a while
        activitySpinnerClass.stopSpinner()
    }
    
    
    @IBAction func signUpBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "firstPageToSignUp", sender: nil)
    }
    
    @IBAction func LoginBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "firstPageToLogIn", sender: nil)
    }
    

}

