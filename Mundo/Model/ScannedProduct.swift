//
//  ScannedProduct.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/19/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class ScannedProduct {
    
    private var _gtinCode: Int!
    private var _gtinType: String!
    private var _brand: String!
    private var _languagecode: String!
    private var _productName: String!
    
    var gtinCode: Int {
        if _gtinCode == nil {
            _gtinCode = 0000000000
        }
        return _gtinCode
    }
    
    var gtinType: String {
        if _gtinType == nil {
            _gtinType = "unknown"
        }
        return _gtinType
    }
    
    var brand: String {
        if _brand == nil {
            _brand = "Brandless"
        }
        return _brand
    }
    
    var languagecode: String {
        if _languagecode == nil {
            _languagecode = "en"
        }
        return _languagecode
    }
    
    var productName: String {
        if _productName == nil {
            _productName = "No-Name-Prod."
        }
        return _productName
    }
    
    init(gtinCode: Int, gtinType: String, brand: String, langaugeCode: String, productName: String) {
        self._gtinCode = gtinCode
        self._gtinType = gtinType
        self._brand = brand
        self._languagecode = langaugeCode
        self._productName = productName
    }
}
