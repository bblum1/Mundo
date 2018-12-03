//
//  WatchlistItem.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/3/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class WatchlistItem {
    
    private var _ticker: String!
    private var _company: String!
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
    
    init(ticker: String, company: String, latestPrice: Float) {
        self._ticker = ticker
        self._company = company
        self._latestPrice = latestPrice
    }
    
}
