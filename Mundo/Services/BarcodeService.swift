//
//  BarcodeService.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/12/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
// Class object that takes barcode --> receives stock information --> Sends stock info back out

import Foundation

class BarcodeService {
    
    let dbURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/get_corp.php"
    let apiURL = "https://mignify.p.mashape.com/gtins/v1.0/productsToGtin?gtin="
    
    var stockTicker = ""
    
    func makeBarcodeCall(gtin: String, completionHandler: @escaping (String?, Error?)->Void) {
        
        let requestURL = NSURL(string: apiURL+gtin)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.setValue("E8XSolZrA8msheqp4XMvj5RPzI78p1JOG8Rjsneu2FyTjg0khg", forHTTPHeaderField: "X-Mashape-Key")
        request.httpMethod = "GET"
        
        // TODO: Change the name of the two tasks to differentiate
        // First call goes to Mashape API to get brand
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
                let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                let thePayload = myJSON!["payload"]
                
                if let parseJSON = thePayload as? Dictionary<String, Any> {
                    print("BOO YAA JSON: \(parseJSON)")
                    
                    if let results = parseJSON["results"] as? [Dictionary<String, String>] {
                        
                        if results.count > 0, let brand = results[0]["brand"] {
                            print("THE BRAND: \(brand)")
                            
                            // Send brand name as request to receive stock ticker
                            let requestURL = NSURL(string: self.dbURL)
                            let request = NSMutableURLRequest(url: requestURL! as URL)
                            request.httpMethod = "POST"
                            
                            let postParameters = "brand="+brand
                            request.httpBody = postParameters.data(using: String.Encoding.utf8)
                            
                            // TODO: Second task, change name here
                            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                                data, response, error in
                                
                                if error != nil {
                                    print("error is \(String(describing: error))")
                                    return
                                }
                                
                                do {
                                    let ourJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                    
                                    if let parseJSON = ourJSON {
                                        
                                        let result = parseJSON["result"] as? String
                                        print("result = \(result!)")
                                        
                                        // create the ScannedStockItem
                                        if let symbol = parseJSON["symbol"] as? String {
                                            print("SYMBOL BABY: \(symbol)!!!!!!!!!!")
                                            // get the scanned stock item loaded as we segue
                                            completionHandler(symbol, nil)
                                        }
                                        
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                    completionHandler(nil, error)
                                    
                                }
                            }
                            task.resume()
                        } else {
                            // TODO: PRINT AN ERROR SAYING THAT IT WAS NOT FOUND
                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
