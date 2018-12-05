//
//  CompanyAndProductView.swift
//  Mundo
//
//  Created by Bailey Blum on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class CompanyAndProductView: UIView {
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    
    func setCompanyAndProductView(brandName: String, companyName: String, productName: String, parseDict: Dictionary<String, Any>) {
        
        DispatchQueue.main.async {
            self.brandNameLabel.text = brandName
            self.companyNameLabel.text = companyName
            self.productNameLabel.text = productName
            self.sectorLabel.text = parseDict["sector"] as? String
            self.industryLabel.text = parseDict["industry"] as? String
        }
        
    }

}
