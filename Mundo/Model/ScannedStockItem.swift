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
    private var _brand: String!
    
    private var _low: Float!
    private var _high: Float!
    private var _latestPrice: Float!
    private var _chartLabels: [String]!
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
        return _company
    }
    
    var brand: String {
        if _brand == nil {
            _brand = "Brandless"
        }
        return _brand
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
    
    var chartLabels: [String] {
        if _chartLabels == nil {
            _chartLabels = ["Nada"]
        }
        return _chartLabels
    }
    
    var chartPrices: [Float] {
        if _chartPrices == nil {
            _chartPrices = [0.00]
        }
        return _chartPrices
    }
    
    init(stockItemDict: Dictionary<String, Any>) {
        self._ticker = (stockItemDict["symbol"] as! String)
        self._company = (stockItemDict["company"] as! String)
        self._brand = (stockItemDict["brand"] as! String)
        
        if let lowvar = stockItemDict["low"] {
            self._low = lowvar as? Float
        }
        //self._low = (stockItemDict["low"] as! Float)
        if let highvar = stockItemDict["high"] {
            self._high = highvar as? Float
        }
        //self._high = (stockItemDict["high"] as! Float)
        if let latevar = stockItemDict["latestPrice"] {
            self._latestPrice = latevar as? Float
        }
        //self._latestPrice = (stockItemDict["latestPrice"] as! Float)
        
        self._chartLabels = (stockItemDict["chartLabels"] as! [String])
        self._chartPrices = (stockItemDict["chartPrices"] as! [Float])
    }
    
}
