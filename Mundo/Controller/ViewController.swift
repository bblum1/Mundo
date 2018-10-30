//
//  ViewController.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/28/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func moveToScan(_ sender: Any) {
        performSegue(withIdentifier: "mainToScan", sender: nil)
    }
    

}

