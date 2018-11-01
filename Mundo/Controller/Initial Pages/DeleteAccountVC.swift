//
//  DeleteAccountVC.swift
//  Mundo
//
//  Created by Bailey Blum on 10/31/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class DeleteAccountVC: UIViewController {
    
    let linkURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/delete.php"
    
    @IBOutlet weak var deleteAccountBttn: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "deleteAccountToLogin", sender: nil)
    }
    
    @IBAction func deleteAccountBtnTapped(_ sender: Any) {
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
        
        performSegue(withIdentifier: "deleteAccountToFirstPage", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
