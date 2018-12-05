//
//  FundamentalsService.swift
//  Mundo
//
//  Created by Bailey Blum on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class FundamentalsService {
    // function that takes in ticker symbol and range that we want to display chart data for
    func callFundamentalsData(ticker: String, completionHandler: @escaping (Dictionary<String, Any>?, Error?)->Void) {
        
        let apiURL = "https://api.robinhood.com/fundamentals/\(ticker)/"
        let requestURL = NSURL(string: apiURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            do {
                let returnJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                print("GOT MY JSON AFTER GET::::\(String(describing: returnJSON))")
                var newDict: Dictionary<String, Any> = [:]
                
                var open = Float(0.00)
                var city = String("Unknown")
                var state = String("Unknown")
                
                
                if let parseJSON = returnJSON as? Dictionary<String, Any> {
                    print("GOT MY JSON AFTER GET::::\(parseJSON)")
                    
                    if let returnOpen = parseJSON["open"] as? Float {
                        open = returnOpen
                    }
                    
                    if let returnCity = parseJSON["headquarters_city"] as? String {
                        city = returnCity
                    }
                    
                    if let returnState = parseJSON["headquarters_state"] as? String {
                        state = returnState
                    }
                    
                    newDict["open"] = parseJSON["open"]
                    newDict["high"] = parseJSON["high"]
                    newDict["low"] = parseJSON["low"]
                    newDict["description"] = parseJSON["description"]
                    newDict["city"] = city
                    newDict["state"] = state
                    newDict["market_cap"] = parseJSON["market_cap"]
                    newDict["high_52_weeks"] = parseJSON["high_52_weeks"]
                    newDict["low_52_weeks"] = parseJSON["low_52_weeks"]
                    newDict["ceo"] = parseJSON["ceo"]
                    newDict["sector"] = parseJSON["sector"]
                    newDict["industry"] = parseJSON["industry"]
                    newDict["num_employees"] = parseJSON["num_employees"]
                    newDict["year_founded"] = parseJSON["year_founded"]
                    
                    print("NEWDICT: \(newDict)")
                    
                    completionHandler(newDict, nil)
                    
                }
                
            } catch {
                print(error.localizedDescription)
                completionHandler(nil, error)
            }
        }
        task.resume()
        
        
        
        
    }
}
