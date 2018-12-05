//
//  StockInfoVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/19/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit
import Highcharts

class StockInfoVC: UIViewController {
    
    let currUserEmail = "btrossen@nd.edu"
    
    var activityIndicator = ActivitySpinnerClass()
    
    // Use this class to make calls with a stock symbol and range of chart data
    var stockInfoService = StockInfoService()
    
    // Use this class to make calls to functions related to user and watchlist
    var userService = UserService()
    
    // Use this class to make calls to fundamentals data of Robinhood.
    var fundamentalsInfoService = FundamentalsInfoService()
    
    // Use this class as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    // String data is passed from previous view controller
    var stockTickerString = ""
    var scannedBrandString = ""
    var scannedProductString = ""
    
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var ceoLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var high52Label: UILabel!
    @IBOutlet weak var low52Label: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var employeesLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    var chartView: HIChartView!
    
    @IBOutlet weak var tableView: UITableView!
    var similarStockService = SimilarStockService()
    var similarStocks = [SimilarStockItem]()
    
    @IBOutlet weak var SegmentedControlButton: UISegmentedControl!
    
    var watchlistStocks: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startSpinner(viewcontroller: self)
        
        //Load the Robinhood Fundamentals Data from the Robinhood API and FundamentalsInfoService file.
        fundamentalsInfoService.callFundamentalsData(ticker: stockTickerString, completionHandler: {(responseDict, error) in
            
            /*if let parseDict = responseDict {
                self.openLabel.text = parseDict["open"] as? String
                self.highLabel.text = parseDict["high"] as? String
                self.descriptionLabel.text = parseDict["description"] as? String
                self.cityLabel.text = parseDict["city"] as? String
                self.stateLabel.text = parseDict["state"] as? String
                self.ceoLabel.text = parseDict["ceo"] as? String
                self.marketCapLabel.text = parseDict["market_cap"] as? String
                self.high52Label.text = parseDict["high_52_weeks"] as? String
                self.low52Label.text = parseDict["low_52_weeks"] as? String
                self.sectorLabel.text = parseDict["sector"] as? String
                self.industryLabel.text = parseDict["industry"] as? String
                self.employeesLabel.text = parseDict["num_employees"] as? String
                self.yearLabel.text = parseDict["year_founded"] as? String
                
            } */
            
            
        })
        
        // Load the users watchlist
        // TODO: Add a way to store current user, will have to use Keychain
        userService.loadUserWatchlist(email: currUserEmail, completionHandler: {(responseArray, error) in
            print("RESPONSE ARRAY OF BLAKE STOCKS::::\(responseArray)")
            if let returnedStocks = responseArray {
                self.watchlistStocks = returnedStocks
            }
            
            DispatchQueue.main.async {
                
                if self.watchlistStocks.contains(self.stockTickerString) {
                    // Already in watchlist, set as checkmark
                    self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
                } else {
                    // Not in watchlist, make it a plus
                    self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
                }
            }
            
        })
        
        // Load the chart for the stock that was scanned
        stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
            
            DispatchQueue.main.async {
                
                // Load the scannedStockItem object with return item
                var newDict = responseJSON!
                newDict["brand"] = self.scannedBrandString.localizedCapitalized
                
                self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                                
                // Load main stock view using Highcharts
                self.loadChartView()
                
                self.activityIndicator.stopSpinner()
            }
        })
        
        // Set tableView of top 5 stocks in the same industry
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 254/255, green: 255/255, blue: 240/255, alpha: 1.00)
        
        // Assign the table data for the similar stocks
        similarStockService.loadSimilarStocks(ticker: stockTickerString, completionHandler: {(responseArray, error) in
            print("RESPONSE ARRAY::::: \(String(describing: responseArray))")
            
            if let parseResponse = responseArray {
                
                let myGroup = DispatchGroup()
                
                for item in parseResponse {
                    
                    myGroup.enter()
                    if let tickerSymbol = item["symbol"] {
                        
                        // Make API Call with each symbol
                        self.stockInfoService.callChartData(ticker: tickerSymbol, range: "1d", completionHandler: {(response, error) in
                            
                            if let stockInfoDict = response {
                                if let company = stockInfoDict["company"] as? String {
                                    if let latestPrice = stockInfoDict["latestPrice"] as? Float {
                                        
                                        print("RESPONSE JSON:::: \(company), \(latestPrice)")
                                        // Crear new SimilarStockItem
                                        let stockItem = SimilarStockItem(ticker: tickerSymbol, company: company, latestPrice: latestPrice)
                                        
                                        // Once the new stock item is appended, send updated array back
                                        self.similarStocks.append(stockItem)
                                        print("UPDATED ARRAY:::::::: \(self.similarStocks)")
                                        
                                        // reload the tableView
                                        DispatchQueue.main.async {
                                            print("RELOADING with: \(self.similarStocks)")
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                            myGroup.leave()
                        })
                    }
                }
            }
            
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadChartView() {
        
        var dataset:[(time: String, price: Float)] = []
        
        let times = scannedStockItem.chartLabels
        let prices = scannedStockItem.chartPrices
        var counter = 0
        for _ in times {
            dataset.append((time: times[counter], price: prices[counter]))
            counter = counter + 1
        }
        
        //print(dataset)
        
        let priceList = prices.filter() {
            $0 > 0
        }
        
        self.companyNameLabel.text = self.scannedStockItem.company
        self.brandNameLabel.text = self.scannedStockItem.brand
        self.productNameLabel.text = self.scannedProductString
                
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        //options.colors([UIColor(red: 0.81, green: 0.56, blue: 0.95, alpha: 1.0)])
        
        let title = HITitle()
        title.text = scannedStockItem.ticker
        title.style = HIStyle()
        title.style.fontSize = "30px"
        title.style.color = "CB92EF"
        title.style.fontFamily = "Avenir Next"
        
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        //subtitle.style = HIStyle()
        //subtitle.style.fontFamily = "Avenir Next"
        
        let yaxis = HIYAxis()
        yaxis.title = HITitle()
        yaxis.title.text = "Price"
        
        let xaxis = HIXAxis()
        //xaxis.title = HITitle()
        xaxis.labels = HILabels()
        xaxis.labels.enabled = false
        //xaxis.title.text = "Time"
        let date = xaxis.dateTimeLabelFormats
        date?.hour = "%I %p"
        date?.minute = "%I:%M %p"
        
        let plotoptions = HIPlotOptions()
        plotoptions.series = HISeries()
        plotoptions.series.marker = HIMarker()
        plotoptions.series.marker.enabled = false
        plotoptions.series.color = HIColor(uiColor: UIColor(red: 0.81, green: 0.56, blue: 0.95, alpha: 1.0))
        //plotoptions.series.color = HIColor()
        //plotoptions.series.color = UIColor(red: 0.81, green: 0.56, blue: 0.95, alpha: 1.0)
        //plotoptions.series.color = UIColor(red: 206/255, green: 143/255, blue: 242/255, alpha: 1.0) as HIColor()
       
        let line1 = HILine()
        line1.name = scannedStockItem.ticker + " Stock Price"
        line1.data = priceList
        
        let responsive = HIResponsive()
        
        let rules1 = HIRules()
        rules1.condition = HICondition()
        rules1.condition.maxWidth = 500
        responsive.rules = [rules1]
        
        let exporting = HIExporting()
        exporting.enabled = false
        
        let credits = HICredits()
        credits.enabled = false
        
        options.title = title
        options.subtitle = subtitle
        options.yAxis = [yaxis]
        options.xAxis = [xaxis]
        let tooltip = HITooltip()
        tooltip.valuePrefix = "$"
        tooltip.valueSuffix = " USD"
        tooltip.valueDecimals = 2
        tooltip.headerFormat = ""
        options.series = [line1]
        options.credits = credits
        options.tooltip = tooltip
        options.responsive = responsive
        options.plotOptions = plotoptions
        options.exporting = exporting
        
        chartView.options = options
        stockView.addSubview(chartView)
    }
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
    @IBAction func temporaryProfileButton(_ sender: Any) {
        performSegue(withIdentifier: "stockinfoToProfile", sender: nil)
    }
    
    @IBAction func watchListButtonTapped(_ sender: Any) {
        
        if self.watchlistStocks != nil && self.watchlistStocks.contains(self.stockTickerString) {
            
            // Already in watchlist, remove it and switch button back to plus
            userService.removeFromWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
                }
            })
            
            // Remove ticker symbol from self.watchlistStocks
            if let itemToRemoveIndex = self.watchlistStocks.index(of: self.stockTickerString) {
                self.watchlistStocks.remove(at: itemToRemoveIndex)
            }
            
        } else {
            
            // Not in watchlist, add it and switch button back to check
            userService.addToWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
                }
            })
            
            // Add ticker symbol to self.watchlistStocks
            self.watchlistStocks.append(self.stockTickerString)
        }
        
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        var timeSelect = "1d"
        switch SegmentedControlButton.selectedSegmentIndex
        {
        case 0:
            timeSelect = "1d";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    var newDict = responseJSON!
                    newDict["brand"] = self.scannedBrandString.localizedCapitalized
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                    
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                    
                    self.activityIndicator.stopSpinner()
                }
            })
        case 1:
            timeSelect = "1m"
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    var newDict = responseJSON!
                    newDict["brand"] = self.scannedBrandString.localizedCapitalized
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                    
                    self.activityIndicator.stopSpinner()
                }
            })
        case 2:
            timeSelect = "3m";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    var newDict = responseJSON!
                    newDict["brand"] = self.scannedBrandString.localizedCapitalized
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                    
                    self.activityIndicator.stopSpinner()
                }
            })
        case 3:
            timeSelect = "1y";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    var newDict = responseJSON!
                    newDict["brand"] = self.scannedBrandString.localizedCapitalized
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                    
                    self.activityIndicator.stopSpinner()
                }
            })
        case 4:
            timeSelect = "5y";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    var newDict = responseJSON!
                    newDict["brand"] = self.scannedBrandString.localizedCapitalized
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                    
                    self.activityIndicator.stopSpinner()
                }
            })
            
        default:
            break
        }
    }
    
}

// MARK: - UITableViewDataSource
extension StockInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let stock = similarStocks[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SimilarStockCell") as? SimilarStockCell {
            
            cell.configureCell(stock: stock)
            cell.delegate = self
            
            return cell
        } else {
            return SimilarStockCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activityIndicator.startSpinner(viewcontroller: self)
        
        // Recreate the actions initiated when the screen is first loaded
        
        if let indexPath = tableView.indexPathForSelectedRow {
            print("SELECTED STOCK IS:::::::\(similarStocks[indexPath.row])::\(similarStocks[indexPath.row].ticker)")
            let selectedStock = similarStocks[indexPath.row]
            
            self.stockTickerString = selectedStock.ticker
            
        } else {
            self.stockTickerString = "TSLA"
        }
        
        self.scannedBrandString = "--"
        self.scannedProductString = "--"
        
        self.similarStocks = []  // Refresh tableView data
        
        // Load the users watchlist
        userService.loadUserWatchlist(email: currUserEmail, completionHandler: {(responseArray, error) in
            
            if let returnedStocks = responseArray {
                self.watchlistStocks = returnedStocks
            }
            
            DispatchQueue.main.async {
                
                if self.watchlistStocks.contains(self.stockTickerString) {
                    // Already in watchlist, set as checkmark
                    self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
                } else {
                    // Not in watchlist, make it a plus
                    self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
                }
            }
            
        })
        
        // Load the chart for the stock that was scanned
        stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
            
            DispatchQueue.main.async {
                
                // Load the scannedStockItem object with return item
                var newDict = responseJSON!
                newDict["brand"] = self.scannedBrandString.localizedCapitalized
                
                self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                
                // Load main stock view using Highcharts
                self.loadChartView()
                
                self.activityIndicator.stopSpinner()
            }
        })
        
        // Assign the table data for the similar stocks
        similarStockService.loadSimilarStocks(ticker: stockTickerString, completionHandler: {(responseArray, error) in
            print("RESPONSE ARRAY::::: \(String(describing: responseArray))")
            
            if let parseResponse = responseArray {
                
                let myGroup = DispatchGroup()
                
                for item in parseResponse {
                    
                    myGroup.enter()
                    if let tickerSymbol = item["symbol"] {
                        
                        // Make API Call with each symbol
                        self.stockInfoService.callChartData(ticker: tickerSymbol, range: "1d", completionHandler: {(response, error) in
                            
                            if let stockInfoDict = response {
                                if let company = stockInfoDict["company"] as? String {
                                    if let latestPrice = stockInfoDict["latestPrice"] as? Float {
                                        
                                        print("RESPONSE JSON:::: \(company), \(latestPrice)")
                                        // Crear new SimilarStockItem
                                        let stockItem = SimilarStockItem(ticker: tickerSymbol, company: company, latestPrice: latestPrice)
                                        
                                        // Once the new stock item is appended, send updated array back
                                        self.similarStocks.append(stockItem)
                                        print("UPDATED ARRAY:::::::: \(self.similarStocks)")
                                        
                                        // reload the tableView
                                        DispatchQueue.main.async {
                                            print("RELOADING with: \(self.similarStocks)")
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                            myGroup.leave()
                        })
                    }
                }
            }
            
        })
        
    }
}

extension StockInfoVC: SimilarStockDelegate {
    
    func didTapCell(_ cell: SimilarStockCell) {
        
    }
}
