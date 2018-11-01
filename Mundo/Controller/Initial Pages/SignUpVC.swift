//
//  SignUpVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var signUpBttn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    
    var textFieldPosition: CGFloat = 0.00
    var textFieldHeight: CGFloat = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the functions that check the sign up boxes
        emailTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
        
        signUpBttn.isEnabled = false
        signUpBttn.setTitleColor(UIColor.lightGray, for: .normal)
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        retypePasswordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        // TODO: Google these errors
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
// NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // TODO: Google these errors
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            // Find out target Y
            let targetY = view.frame.size.height - keyboardRect.height - 20 - textFieldHeight
            
            let positionTextFieldY = textFieldPosition
            
            let difference = targetY - positionTextFieldY
            
            print("difference = \(difference)")
            
            if difference < 0 {
                view.frame.origin.y = difference
            } else {
                view.frame.origin.y = 0
            }
            
        } else {
            view.frame.origin.y = 0
        }
        
    }
    
    // function that will activate signUpButton if textfields filled
    @objc func editingChanged(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            // if first character is a space
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        
        guard
            let email = emailTextField.text, !email.isEmpty,
            //emailExistsInDB(emailAddressString: email) != true, // add once created
            let password = passwordTextField.text, !password.isEmpty,
            let password_count = passwordTextField.text, !(password_count.count < 6),
            let retypePassword = retypePasswordTextField.text, retypePassword == password,
            isValidEmailAddress(emailAddressString: email), isValidEmailAddress(emailAddressString: email) != false
            else {
                signUpBttn.isEnabled = false
                signUpBttn.setTitleColor(UIColor.lightGray, for: .normal)
                return
        }
        signUpBttn.isEnabled = true
        // TODO: Change this to purple
        signUpBttn.setTitleColor(UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1.0), for: .normal)
    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldPosition = textField.frame.origin.y
        textFieldHeight = textField.frame.size.height
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    // Hides keyboard once the user is done editing
    func hideKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        retypePasswordTextField.resignFirstResponder()
    }
    
    // function that checks for a valid email
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    /*func emailExistsInDB(emailAddressString: String) -> Bool {
        // Use this to check if an account with this email already exists in DB
    }*/
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "signUpToFirstPage", sender: nil)
    }
    

    @IBAction func signUpBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "signUpToScanner", sender: nil)
    }
}
