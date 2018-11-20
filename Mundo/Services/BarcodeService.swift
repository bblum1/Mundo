//
//  BarcodeService.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/12/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class BarcodeService {
    
    let dbURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/get_corp.php"
    let apiURL = "https://mignify.p.mashape.com/gtins/v1.0/productsToGtin?gtin="
    
    func makeBarcodeCall(gtin: String) {
        
        let requestURL = NSURL(string: apiURL+gtin)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.setValue("E8XSolZrA8msheqp4XMvj5RPzI78p1JOG8Rjsneu2FyTjg0khg", forHTTPHeaderField: "X-Mashape-Key")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
                let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = myJSON as? Dictionary<String, Dictionary<String, Any>> {
                    print("BOO YAA JSON: \(parseJSON)")
                    
                    // Parse the JSON returned from Mashape API and store to object
//                    let gtinCode = parseJSON["payload"]!["gtinCode"] as? Int
//                    let gtinType = parseJSON["payload"]!["gtinType"] as? String
                    
//                    let languageCode: String?
//                    let productName: String?
//
                    let results = parseJSON["payload"]!["results"] as? [Dictionary<String, String>]
                        
                        
//                        languageCode = results[0]["languageCode"]
//                        productName = results[0]["productName"]
                    
                    if let brand = results![0]["brand"] {
                        // Send the brand name as POST request to DB
                        let requestURL = NSURL(string: self.dbURL)
                        let request = NSMutableURLRequest(url: requestURL! as URL)
                        request.httpMethod = "POST"
                        
                        let postParameters = "brand="+brand
                        request.httpBody = postParameters.data(using: String.Encoding.utf8)
                        
                        let task = URLSession.shared.dataTask(with: request as URLRequest) {
                            data, response, error in
                            
                            if error != nil {
                                print("error is \(String(describing: error))")
                                return
                            }
                            
                            do {
                                // TODO: Parse the return from our database response
                                let ourJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                
                                // TODO: Change this to
                                if let parseJSON = ourJSON {
                                    let result = parseJSON["result"] as? String
                                    let corporation = parseJSON["corporation"] as? String
                                    
                                    print(result as Any)
                                    print("CORPORATION BABY!!!!!", corporation as Any)
                                }
                            } catch {
                                print(error)
                            }
                        }
                        task.resume()
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
