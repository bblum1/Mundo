//
//  SimilarStockService.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/20/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class SimilarStockService {
    
    let similarStockURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/suggested_companies.php/?symbol="
    
    // Function makes call to our DSG1 DB for top 5 similar tickers
    func loadSimilarStocks(ticker: String, completionHandler: @escaping ([Dictionary<String, String>]?, Error?)->Void) {
        
        print("IN LoadSimilarStocks...")
        
        // Make API call with stock ticker, with return top 5 similar tickers
        let requestURL = NSURL(string: similarStockURL+ticker)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            do {
                let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray
                
                print("MYJSON::: \(myJSON)")
                
                // parseArray contains all 5 tickers
                if let parseArray = myJSON as? [Dictionary<String, String>] {
                    
                    /*while i < parseArray.count {
                        
                        let theSymbol = parseArray[i]["symbol"]
                        
                        print("At \(i), with symbol: \(theSymbol)")
                        
                        // Use other functions to make API call to get company name and latest price
                        self.loadItem(symbol: theSymbol!, loadedArray: ansArray, completionHandler: {(loadedArray, error) in
                            // Return updated array and update the count of iterations
                            print("RESPONSE ARRAY1 :::: \(loadedArray)")
                            ansArray = loadedArray ?? ansArray
                            i += 1
                            print("i == \(i)")
                        })
                        
                    }*/
                    completionHandler(parseArray, nil)
                }
            } catch {
                print(error)
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    // Function will make API call to the symbol
    func loadItem(symbol: String, loadedArray: [SimilarStockItem], completionHandler: @escaping ([SimilarStockItem]?, Error?)->Void) {
        
        var similarStocks = loadedArray
        
        do {
            // Make API call
            let stockInfoService = StockInfoService()
            
            stockInfoService.callChartData(ticker: symbol, range: "1d", completionHandler: {(responseJSON, error) in
                
                
                
                if let stockInfoDict = responseJSON {
                    let company = stockInfoDict["company"] as? String ?? "No Company"
                    let latestPrice = stockInfoDict["latestPrice"] as? Float ?? Float(0.00)
                    let openingPrice = stockInfoDict["open"] as? Float ?? Float(0.00)
                    
                    print("RESPONSE JSON:::: \(company), \(latestPrice), \(openingPrice)")
                    
                    
                    // Crear new SimilarStockItem
                    let stockItem = SimilarStockItem(ticker: symbol, company: company, latestPrice: latestPrice, openingPrice: openingPrice)
                    
                    // Once the new stock item is appended, send updated array back
                    similarStocks.append(stockItem)
                    completionHandler(similarStocks, nil)
                        
                } else {
                    completionHandler(similarStocks, nil)
                }
            })
            
        } catch {
            print(error)
            completionHandler(nil, error)
        }
        
    }
}
