//
//  CompanyDescriptionView.swift
//  Mundo
//
//  Created by Bailey Blum on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class CompanyDescriptionView: UIView {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var ceoLabel: UILabel!
    @IBOutlet weak var employeesLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    func setCompanyDetailsView(parseDict: Dictionary<String, Any>) {
        // AboutCompany View/ TextView
        self.descriptionLabel.text = parseDict["description"] as? String
        self.ceoLabel.text = parseDict["ceo"] as? String
        self.cityLabel.text = parseDict["city"] as? String
        self.stateLabel.text = parseDict["state"] as? String
        self.employeesLabel.text = parseDict["num_employees"] as? String
        self.yearLabel.text = parseDict["year_founded"] as? String
    }
}
