//
//  UserService.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/1/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation

class UserService {
    
    // TODO: Have
    func loadUserWatchlist(userEmail: String) -> [SimilarStockItem] {
        
        // Make API call with stock ticker
        let linkURL = "http://dsg1.crc.nd.edu/cse30246/groms/dbaccess/watchlist.php?=\(userEmail)"
        
        // Load each one into the array
        let stockItem = SimilarStockItem(ticker: "BUD", company: "Budweiser", latestPrice: 77.00)
        
        return [stockItem]
    }
}
