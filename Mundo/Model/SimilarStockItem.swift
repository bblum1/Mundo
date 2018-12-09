//
//  SimilarStockItem.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/30/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class SimilarStockItem {
    
    private var _ticker: String!
    private var _company: String!
    private var _openingPrice: Float!
    private var _latestPrice: Float!
    
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
    
    var latestPrice: Float {
        if _latestPrice == nil {
            _latestPrice = 0.00
        }
        return _latestPrice
    }
    
    var openingPrice: Float {
        if _openingPrice == nil {
            _openingPrice = 0.00
        }
        return _openingPrice
    }
    
    init(ticker: String, company: String, latestPrice: Float, openingPrice: Float) {
        self._ticker = ticker
        self._company = company
        self._openingPrice = openingPrice
        self._latestPrice = latestPrice
    }
    
}
