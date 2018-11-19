//
//  BarcodeService.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/12/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class BarcodeService {
    
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
                
                if let parseJSON = myJSON {
                    print("BOO YAA JSON: \(parseJSON)")
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
