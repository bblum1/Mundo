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
    
    var scannedStockItem: ScannedStockItem!
    var similarStockService: SimilarStockService()
    
    func makeBarcodeCall(gtin: String) -> ScannedStockItem {
        print("THE STRING IN BARCODE SERVICE:", gtin)
        
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
                print("MYJSON: \(myJSON)")
                
                let thePayload = myJSON!["payload"]
                
                if let parseJSON = thePayload as? Dictionary<String, Any>{
                    print("BOO YAA JSON: \(parseJSON)")
                    
                    // Parse the JSON returned from Mashape API and store to object
//                    let gtinCode = parseJSON["payload"]!["gtinCode"] as? Int
//                    let gtinType = parseJSON["payload"]!["gtinType"] as? String
                    
//                    let languageCode: String?
//                    let productName: String?
//
                    if let results = parseJSON["results"] as? [Dictionary<String, String>] {
                        
                        if let brand = results[0]["brand"] {
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
                                        let symbol = parseJSON["symbol"] as? String
                                        
                                        print("result = \(result!)")
                                        print("SYMBOL BABY: \(symbol!)!!!!!!!!!!")
                                        
                                        // create the ScannedStockItem and return it
                                        self.scannedStockItem = ScannedStockItem(ticker: symbol ?? "N/A")
                                        
                                        // TODO: Get top 5-8 stocks also in the industry
                                        // similarStockService.receiveIndustryStocks(industry: industry)
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                            task.resume()
                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
        return self.scannedStockItem
    }
    
}
