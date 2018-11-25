//
//  ScannedStockItem.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/20/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
// This is the item generated and returned from our own queries after a product is scanned.

import Foundation

class ScannedStockItem {
    
    private var _ticker: String!
    private var _company: String!
    
    private var _low: Float!
    private var _high: Float!
    private var _latestPrice: Float!
    private var _chartPrices: [Float]!
    
    var ticker: String {
        if _ticker == nil {
            _ticker = "N/A"
        }
        return _ticker
    }
    
    var company: String {
        if _company == nil {
            _company = "NoCo."
        }
        return _ticker
    }
    
    var low: Float {
        if _low == nil {
            _low = 0.00
        }
        return _low
    }
    
    var high: Float {
        if _high == nil {
            _high = _low + 1.00
        }
        return _high
        
    }
    
    var latestPrice: Float {
        if _latestPrice == nil {
            _latestPrice = _low
        }
        return _latestPrice
    }
    
    var chartPrices: [Float] {
        if _chartPrices == nil {
            _chartPrices = [0.00]
        }
        return _chartPrices
    }
    
    // initializer function
    func callChartData(ticker: String, range: String) -> ScannedStockItem {
        
        self._ticker = ticker
        
        let apiURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols=\(ticker)&types=quote,news,chart&range=\(range)"
        let requestURL = NSURL(string: apiURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "GET"
        
        // Call the IEX API to get chart data
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
                let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = myJSON as? Dictionary<String, AnyObject>{
                    
                    // Get basic information on the stock, unrelated to range
                    if let quote = parseJSON["quote"] as? Dictionary<String, AnyObject> {
                        print("THE QUOTE: \(quote)")
                        self._company = quote["companyName"] as? String
                        
                        self._high = quote["high"] as? Float
                        self._low = quote["low"] as? Float
                        self._latestPrice = quote["latestPrice"] as? Float
                    }
                    
                    // Parse chart to get array of all prices in range
                    if let chart = parseJSON["chart"] as? [Dictionary<String, AnyObject>] {
                        
                        var chartPrices: [Float] = []
                        
                        if range == "1d" {
                            for priceItem in chart {
                                // TODO: reformat and use dates for scrollable interactions on line
                                //let label = priceItem["label"] as? String
                                let marketAverage = priceItem["marketAverage"] as! Float
                                
                                chartPrices.append(marketAverage)
                            }
                            
                            self._chartPrices = chartPrices
                        } else {
                            // keys for prices are different for 1m and 1y ranges
                            for priceItem in chart {
                                // TODO: reformat and use dates for scrollable interactions on line
                                // let label = priceItem["date"] as? String
                                let closePrice = priceItem["close"] as! Float
                                
                                chartPrices.append(closePrice)
                            }
                            
                            self._chartPrices = chartPrices
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        return self
    }
}
