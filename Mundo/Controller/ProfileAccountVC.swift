//
//  ProfileAccountVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/3/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit
import Highcharts

class ProfileAccountVC: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stockView: UIView!
    
    @IBOutlet weak var watchlistTableView: UITableView!
    var watchlistSymbols: [String] = []
    var watchlistSectors: [String] = []
    var watchlistStocks = [WatchlistItem]()
    
    let currUserEmail = "btrossen@nd.edu"
    
    var stockTickerString = ""
    var scannedBrandString = ""
    var scannedProductString = ""
    
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
                for tuple in returnedStocks {
                    self.watchlistSymbols.append(tuple.0)
                    self.watchlistSectors.append(tuple.1)
                }
                //print("WATCHLIST SECTORS: \(self.watchlistSectors)")
                
                //self.watchlistSymbols = returnedStocks
                
                let myGroup = DispatchGroup()
                
                // Make API call with each symbol, only need full Watchlist items here
                // NOTE: In StockInfoVC, we just needed the quick array to update + and - buttons
                for symbol in self.watchlistSymbols {
                    
                    myGroup.enter()
                    self.stockInfoService.callChartData(ticker: symbol, range: "1d", completionHandler: {(responseDict, error) in
                        
                        if let stockInfoDict = responseDict {
                            
                            let company = stockInfoDict["company"] as? String ?? "No Company"
                            let latestPrice = stockInfoDict["latestPrice"] as? Float ?? Float(0.00)
                            let openingPrice = stockInfoDict["open"] as? Float ?? Float(0.00)

                            let watchlistItem = WatchlistItem(ticker: symbol, company: company, openingPrice: openingPrice, latestPrice: latestPrice)
                            
                            self.watchlistStocks.append(watchlistItem)
                            
                            DispatchQueue.main.async {
                                self.watchlistTableView.reloadData()
                                self.loadChartView()
                            }
                            
                        }
                        myGroup.leave()
                    })
                }
            }
            
        })
        //loadChartView()
        watchlistTableView.delegate = self
        watchlistTableView.dataSource = self
    }
    
    // Prepare to transfer returned stock after scan to StockInfoVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? StockInfoVC
        viewController?.stockTickerString = self.stockTickerString
        viewController?.scannedBrandString = self.scannedBrandString
        viewController?.scannedProductString = self.scannedProductString
    }
    
    func loadChartView() {
        //print("AFTER CALL: WATCHLIST SECTORS: \(self.watchlistSectors)")
        let chartView = HIChartView(frame: stockView.bounds)
        let options = HIOptions()
        let chart = HIChart()
        chart.plotBackgroundColor = HIColor()
        chart.plotBorderWidth = NSNumber()
        chart.plotShadow = 0
        chart.type = "pie"
        
        let title = HITitle()
        title.text = "My Likings Breakdown"
        
        let tooltip = HITooltip()
        tooltip.pointFormat = "{series.name}: <b>{point.percentage:.1f}%</b>"
        
        let exporting = HIExporting()
        exporting.enabled = false
        
        let credits = HICredits()
        credits.enabled = false
        
        let plotoptions = HIPlotOptions()
        plotoptions.pie = HIPie()
        plotoptions.pie.allowPointSelect = 1
        plotoptions.pie.cursor = "pointer"
        plotoptions.pie.dataLabels = HIDataLabels()
        plotoptions.pie.dataLabels.enabled = 0
        plotoptions.pie.showInLegend = 1
        
        let pie = HIPie()
        pie.name = "Industries"
        
        var sectorDict = Dictionary<String, Double>()
        var length = Double(0.00)
        print("WATCHLIST SECTORS: \(self.watchlistSectors)")
        for sector in self.watchlistSectors {
            length = length + 1
            if let val = sectorDict[sector] {
                sectorDict[sector] = val + 1
            }
            else {
                sectorDict[sector] = 1
            }
        }
        
        print("Length: \(length)")
        
        for (sector, total) in sectorDict {
            sectorDict[sector] = ((total / length) * 100)
        }
        
        var data : [Dictionary<String, Any>] = []
        var inner : Dictionary<String, Any> = [:]
        
        for (sector, percent) in sectorDict {
            inner["name"] = sector
            inner["y"] = percent
            data.append(inner)
        }
        
        print("Data: \(data)")
        
        pie.data = data
        
        options.chart = chart
        options.title = title
        options.tooltip = tooltip
        options.plotOptions = plotoptions
        options.series = [pie]
        options.exporting = exporting
        options.credits = credits
        
        chartView.options = options
        stockView.addSubview(chartView)
        
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
