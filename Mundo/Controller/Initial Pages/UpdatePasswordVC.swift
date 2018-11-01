//
//  UpdatePasswordVC.swift
//  Mundo
//
//  Created by Bailey Blum on 10/31/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class UpdatePasswordVC: UIViewController {
    
    let linkURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/update_password.php"
    
    @IBOutlet weak var updatePasswordBttn: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldCurrentPassword: UITextField!
    @IBOutlet weak var textFieldNewPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        let requestURL = NSURL(string: linkURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        let email=textFieldEmail.text
        let currentPassword=textFieldCurrentPassword.text
        let newPassword=textFieldNewPassword.text
        
        let postParameters = "email="+email!+"&currentPassword="+currentPassword!+"&newPassword="+newPassword!;
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
        
        performSegue(withIdentifier: "updatePasswordToScanner", sender: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "updatePasswordToLogin", sender: nil)
    }
    

}
