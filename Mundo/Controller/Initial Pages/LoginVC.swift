//
//  LoginVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    let linkURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/login.php"


    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var signInBttn: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "logInToFirstPage", sender: nil)
    }
    
    @IBAction func deleteAccountBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "loginToDeleteAccount", sender: nil)
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        performSegue(withIdentifier: "loginToUpdatePassword", sender: nil)
    }
    
    @IBAction func signInBttnTapped(_ sender: Any) {
        let requestURL = NSURL(string: linkURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        let email=textFieldEmail.text
        let password=textFieldPassword.text
        
        let postParameters = "email="+email!+"&password="+password!;
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
             let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
             
             if let parseJSON = myJSON {
                var msg : String!
                var msgEmail : String!
                msgEmail = parseJSON["email"] as? String
                msg = parseJSON["result"] as? String
                print(msg)
                print(msgEmail)
             }
             } catch {
                print(error)
             }
        }
        task.resume()
        
        performSegue(withIdentifier: "logInToScanner", sender: nil)
    }
    
}
