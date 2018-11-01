//
//  SignUpVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    let linkURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/adduser.php"

    @IBOutlet weak var signUpBttn: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "signUpToFirstPage", sender: nil)
    }
    

    @IBAction func signUpBttnTapped(_ sender: Any) {
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
                    msg = parseJSON["result"] as? String
                    print(msg)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        performSegue(withIdentifier: "signUpToScanner", sender: nil)
    }
}
