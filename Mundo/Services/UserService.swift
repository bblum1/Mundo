//
//  UserService.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/1/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class UserService {
    
    // Function will add a stock ticker to their watchlist with POST request
    func addToWatchlist(email: String, symbol: String, completionHandler: @escaping (String?, Error?)->Void) {
        
        let dbURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/add_watchlist.php"
        
        let requestURL = NSURL(string: dbURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        let json = ["email": email, "symbol": symbol]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            do {
                let returnJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                print("GOT MY JSON AFTER POST::::\(String(describing: returnJSON))")
                
                if let parseJSON = returnJSON as? Dictionary<String, Any> {
                    print("GOT MY JSON AFTER POST::::\(parseJSON)")
                    if let result = parseJSON["result"] as? String {
                        if result == "Failure" {
                            // TODO: Send alert to screen saying that add failed
                            print("ADDING STOCK: \(symbol) FAILED")
                        } else {
                            completionHandler(result, nil)
                        }
                    }
                }
                
            } catch {
                print(error.localizedDescription)
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    // Function will return all the stock tickers in their watchlist with GET request
    func loadUserWatchlist(email: String, completionHandler: @escaping ([String]?, Error?)->Void) {
        
        let dbURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/watchlist.php/?email=\(email)"
        
        let requestURL = NSURL(string: dbURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
                let returnJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray
                
                
                
                if let tickersArray = returnJSON as? [Dictionary<String, String>] {
                    
                    var returnArray: [String] = []
                    
                    for dict in tickersArray {
                        if let symbolStr = dict["symbol"] {
                            returnArray.append(symbolStr)
                        }
                    }
                    print("GOT MY TICKERS::::::\(returnArray)")
                    completionHandler(returnArray, nil)
                }
                
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // Function will remove a stock from a user's watchlist
    func removeFromWatchlist(email: String, symbol: String, completionHandler: @escaping (String?, Error?)->Void) {
        
        let dbURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/delete_watchlist.php"
        
        let requestURL = NSURL(string: dbURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        let json = ["email": email, "symbol": symbol]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            do {
                let returnJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                print("GOT MY JSON AFTER POST::::\(String(describing: returnJSON))")
                
                if let parseJSON = returnJSON as? Dictionary<String, Any> {
                    print("GOT MY JSON AFTER POST::::\(parseJSON)")
                    if let result = parseJSON["result"] as? String {
                        if result == "Failure" {
                            // TODO: Send alert to screen saying that delete failed
                            print("ADDING STOCK: \(symbol) FAILED")
                        } else {
                            completionHandler(result, nil)
                        }
                    }
                }
                
            } catch {
                print(error.localizedDescription)
                completionHandler(nil, error)
            }
        }
        task.resume()
        
    }

}
