//
//  StockInfoVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/19/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class StockInfoVC: UIViewController {
    
    var companyNameString = ""
    var tickerString = ""
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var stockTickerLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stockTickerLabel.text = tickerString

    }
    
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
}
