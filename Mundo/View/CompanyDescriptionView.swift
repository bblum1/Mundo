//
//  CompanyDescriptionView.swift
//  Mundo
//
//  Created by Bailey Blum on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class CompanyDescriptionView: UIView {
    
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var ceoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var employeesLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    func setCompanyDetailsView(parseDict: Dictionary<String, Any>) {
        
        DispatchQueue.main.async {
            // AboutCompany View/ TextView
            self.descriptionLabel.text = parseDict["description"] as? String
            self.ceoLabel.text = parseDict["ceo"] as? String
            let city = parseDict["city"] as? String ?? "Unknown City"
            let state = parseDict["state"] as? String ?? "US"
            self.locationLabel.text = "\(city), \(state)"
            if let employeeInt = parseDict["num_employees"] as? Int {
                self.employeesLabel.text = "\(employeeInt)"
            }
            print("some employees::::\(parseDict["num_employees"])")
            if let yearInt = parseDict["year_founded"] as? Int {
                self.yearLabel.text = "\(yearInt)"
            }
            print("some year:::::\(parseDict["year_founded"])")
        }
        
    }
}
