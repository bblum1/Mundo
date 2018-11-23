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
    //private var _company: String!
    
    var ticker: String {
        if _ticker == nil {
            _ticker = "N/A"
        }
        return _ticker
    }
    
    /*var company: String {
        if _company == nil {
            _company = "NoCo."
        }
        return _ticker
    }*/
    
    init (ticker: String) {
        self._ticker = ticker
        //self._company = company
    }
    
}
