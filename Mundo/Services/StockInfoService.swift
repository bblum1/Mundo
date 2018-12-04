//
//  StockInfoService.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/26/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//
//  This class contains the functions that make a call to IEXtrading.com with a stock symbol

import Foundation

class StockInfoService {
    
    // function that takes in ticker symbol and range that we want to display chart data for
    func callChartData(ticker: String, range: String, completionHandler: @escaping (Dictionary<String, Any>?, Error?)->Void) {
        
        let apiURL = "https://api.iextrading.com/1.0/stock/market/batch?symbols=\(ticker)&types=quote,news,chart&range=\(range)"
        let requestURL = NSURL(string: apiURL)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "GET"
        
        var returnJSON = [String: Any]()
        
        returnJSON["symbol"] = ticker
        
        // Call the IEX API to get chart data
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error is \(String(describing: error))")
                return
            }
            
            do {
                if let myJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    
                    if let parseJSON = myJSON[ticker] as? Dictionary<String, Any> {
                        
                        // Get basic information on the stock, unrelated to range
                        if let quote = parseJSON["quote"] as? Dictionary<String, Any> {
                            
                            if let company = quote["companyName"] {
                                returnJSON["company"] = company as! String
                            }
                            
                            if let high = quote["high"] as? NSNumber {
                                returnJSON["high"] = high.floatValue
                            }
                            
                            if let low = quote["low"] as? NSNumber {
                                returnJSON["low"] = low.floatValue
                            }
                            
                            if let latestPrice = quote["latestPrice"] as? NSNumber {
                                returnJSON["latestPrice"] = latestPrice.floatValue
                            }
                        }
                        
                        // Parse chart to get array of all prices in range
                        if let chart = parseJSON["chart"] as? [Dictionary<String, Any>] {
                            
                            var chartPrices: [Float] = []
                            var chartLabels: [String] = []
                            
                            if range == "1d" {
                                for priceItem in chart {
                                    let label = priceItem["label"] as! String
                                    chartLabels.append(label)
                                    
                                    if let marketAverage = priceItem["marketAverage"] as? NSNumber {
                                        chartPrices.append(marketAverage.floatValue)
                                    }
                                }
                                returnJSON["chartLabels"] = chartLabels
                                returnJSON["chartPrices"] = chartPrices
                            } else {
                                // keys for prices are different for 1m and 1y ranges
                                for priceItem in chart {
                                    let label = priceItem["date"] as! String
                                    chartLabels.append(label)
                                    
                                    if let closePrice = priceItem["close"] as? NSNumber {
                                        chartPrices.append(closePrice.floatValue)
                                    }
                                }
                                returnJSON["chartLabels"] = chartLabels
                                returnJSON["chartPrices"] = chartPrices
                            }
                        }
                        completionHandler(returnJSON, nil)
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
