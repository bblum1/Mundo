//
//  ProfileAccountVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/3/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class ProfileAccountVC: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stockView: UIView!
    
    @IBOutlet weak var segmentedChartButton: UISegmentedControl!
    
    @IBOutlet weak var watchlistTableView: UITableView!
    var watchlistSymbols: [String] = []
    var watchlistStocks = [WatchlistItem]()
    
    let currUserEmail = "btrossen@nd.edu"
    
    var activityIndicator = ActivitySpinnerClass()
    
    // Use this class to make calls with a stock symbol and range of chart data
    var stockInfoService = StockInfoService()
    
    // Use this class to make calls to functions related to user and watchlist
    var userService = UserService()
    
    // Use this class as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the user's watchlist tickers
        userService.loadUserWatchlist(email: currUserEmail, completionHandler: {(responseArray, error) in
            
            if let returnedStocks = responseArray {
                // TODO: Delete watchlistSymbols if not needed
                self.watchlistSymbols = returnedStocks
                
                let myGroup = DispatchGroup()
                
                // Make API call with each symbol, only need full Watchlist items here
                // NOTE: In StockInfoVC, we just needed the quick array to update + and - buttons
                for symbol in returnedStocks {
                    
                    myGroup.enter()
                    self.stockInfoService.callChartData(ticker: symbol, range: "1d", completionHandler: {(responseDict, error) in
                        
                        if let stockInfoDict = responseDict {
                            
                            var company = ""
                            var openingPrice = Float(0.00)
                            var latestPrice = Float(0.00)
                            
                            if let returnCompany = stockInfoDict["company"] as? String {
                                company = returnCompany
                            }
                            
                            if let returnLatestPrice = stockInfoDict["latestPrice"] as? Float {
                                latestPrice = returnLatestPrice
                            }
                            
                            if let returnOpeningPrice = stockInfoDict["open"] as? Float {
                                openingPrice = returnOpeningPrice
                            }
                            
                            let watchlistItem = WatchlistItem(ticker: symbol, company: company, openingPrice: openingPrice, latestPrice: latestPrice)
                            
                            self.watchlistStocks.append(watchlistItem)
                            
                            DispatchQueue.main.async {
                                self.watchlistTableView.reloadData()
                            }
                            
                        }
                        myGroup.leave()
                    })
                }
            }
        })
        
        watchlistTableView.delegate = self
        watchlistTableView.dataSource = self
    }
    
}

// MARK: - UITableViewDataSource
extension ProfileAccountVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let stock = watchlistStocks[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell") as? WatchlistCell {
            
            cell.configureCell(stock: stock)
            
            return cell
        } else {
            return WatchlistCell()
        }
    }
    
}
