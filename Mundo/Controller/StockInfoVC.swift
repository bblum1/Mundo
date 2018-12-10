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
    
    var chartView: HIChartView!
    @IBOutlet weak var stockView: UIView!
    
    @IBOutlet weak var addToWatchlistButton: UIButton!
    
    var companyString = ""
    @IBOutlet weak var companyAndProductView: CompanyAndProductView!
    @IBOutlet weak var statsView: StatsView!
    @IBOutlet weak var companyDescriptionView: CompanyDescriptionView!
    
    // Services
    
    var userService = UserService()                     // loads user email and watchlist data
    var stockInfoService = StockInfoService()           // gets chart data and company name for ticker
    var fundamentalsService = FundamentalsService()     // gets fundamentals for stock ticker
    var similarStockService = SimilarStockService()     // finds similar stocks for stock ticker
    
    var currUserEmail = ""
    
    // View objects
    var activityIndicator = ActivitySpinnerClass()
    
    let modalSlideInteractor = ModalSlideInteractor()
    
    // Use this class as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    // String data is passed from previous view controller
    var stockTickerString = ""
    var scannedBrandString = ""
    var scannedProductString = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    var similarStocks = [SimilarStockItem]()
    
    var selectedStockSymbol = ""          // variable stores a stock ticker selected from tableView
    var selectedStockCompany = ""         // variable stores the company string of the selected cell
    
    @IBOutlet weak var SegmentedControlButton: UISegmentedControl!
    
    var watchlistStocks: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cachedEmail = userService.userEmail {
            self.currUserEmail = cachedEmail
        }
        
        activityIndicator.startSpinner(viewcontroller: self)
        
        print("LOADING NOW IN INFO: \(stockTickerString), \(scannedBrandString), \(scannedProductString)")
        
        if stockTickerString != "" {
        
            // Load the chart for the stock that was scanned
            stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    
                    // Load the scannedStockItem object with return item
                    if let theDict = responseJSON {
                        var newDict = theDict
                        newDict["brand"] = self.scannedBrandString.localizedCapitalized
                        
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        self.addToWatchlistButton.isEnabled = true
                        self.activityIndicator.stopSpinner()
                    } else {
                        self.activityIndicator.stopSpinner()
                    }
                }
            })
            
            // Set tableView of top 5 stocks in the same industry
            tableView.delegate = self
            tableView.dataSource = self
            
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
                                    
                                    let company = stockInfoDict["company"] as? String ?? "NoCo."
                                    let latestPrice = stockInfoDict["latestPrice"] as? Float ?? Float(0.00)
                                    let openingPrice = stockInfoDict["open"] as? Float ?? Float(0.00)
                                    
                                    print("RESPONSE JSON:::: \(company), \(latestPrice), \(openingPrice)")
                                    // Crear new SimilarStockItem
                                    let stockItem = SimilarStockItem(ticker: tickerSymbol, company: company, latestPrice: latestPrice, openingPrice: openingPrice)
                                
                                    // Once the new stock item is appended, send updated array back
                                    self.similarStocks.append(stockItem)
                                
                                    // reload the tableView
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        self.loadAllSubViews()
                                    }
                                    
                                }
                                myGroup.leave()
                            })
                        }
                    }
                }
                
            })
            
            userService.loadUserWatchlist(email: currUserEmail, completionHandler: {(responseArray, error) in
                
                if let returnedStocks = responseArray {
                    for tuple in returnedStocks {
                        self.watchlistStocks.append(tuple.0)
                    }
                    //self.watchlistStocks = returnedStocks
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
        } else {
            activityIndicator.stopSpinner()
            addToWatchlistButton.isEnabled = false
            stockInfoService.generalErrorAlert(viewController: self)
        }
    }
    
    func loadAllSubViews() {
        //Load the Robinhood Fundamentals Data from the Robinhood API and FundamentalsInfoService file.
        fundamentalsService.callFundamentalsData(ticker: stockTickerString, completionHandler: {(responseDict, error) in
            print("response dict: \(String(describing: responseDict))")
            
            if let parseDict = responseDict {
                
                // set all the views after Robinhood fundamentals call
                self.companyAndProductView.setCompanyAndProductView(brandName: self.scannedBrandString, companyName: self.companyString, productName: self.scannedProductString, parseDict: parseDict)
                
                self.statsView.setStatsView(parseDict: parseDict)
                
                self.companyDescriptionView.setCompanyDetailsView(parseDict: parseDict)
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
                
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        
        let title = HITitle()
        title.text = scannedStockItem.ticker
        title.style = HIStyle()
        title.style.fontSize = "30px"
        title.style.color = "CB92EF"
        title.style.fontFamily = "Avenir Next"
        
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        
        let yaxis = HIYAxis()
        yaxis.title = HITitle()
        yaxis.title.text = "Price"
        
        let xaxis = HIXAxis()
        xaxis.labels = HILabels()
        xaxis.labels.enabled = false
        let date = xaxis.dateTimeLabelFormats
        date?.hour = "%I %p"
        date?.minute = "%I:%M %p"
        
        let plotoptions = HIPlotOptions()
        plotoptions.series = HISeries()
        plotoptions.series.marker = HIMarker()
        plotoptions.series.marker.enabled = false
        plotoptions.series.color = HIColor(rgb: 206, green: 143, blue: 242)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stockinfoToProfile" {
            let viewController = segue.destination as? ProfileAccountVC
            viewController?.stockTickerString = self.stockTickerString
            viewController?.scannedBrandString = self.scannedBrandString
            viewController?.scannedProductString = self.scannedProductString
        }
        
        if segue.identifier == "stockInfoToPopUp" {
            let viewController = segue.destination as? StockViewPopUpVC
            viewController?.stockTickerString = self.selectedStockSymbol
            viewController?.companyString = self.selectedStockCompany
            viewController?.watchlistStocks = self.watchlistStocks
            viewController?.modalSlideInteractor = self.modalSlideInteractor
            viewController?.transitioningDelegate = self
        }
        
    }
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
    @IBAction func temporaryProfileButton(_ sender: Any) {
        performSegue(withIdentifier: "stockinfoToProfile", sender: nil)
    }
    
    @IBAction func watchListButtonTapped(_ sender: Any) {
        
        if self.watchlistStocks.contains(self.stockTickerString) {
            
            // Already in watchlist, remove it and switch button back to plus
            userService.removeFromWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    
                    // Remove ticker symbol from self.watchlistStocks
                    if let itemToRemoveIndex = self.watchlistStocks.index(of: self.stockTickerString) {
                        self.watchlistStocks.remove(at: itemToRemoveIndex)
                    }
                    
                    // Update button and tableView
                    self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
                    self.tableView.reloadData()
                }
            })
            
        } else {
            
            // Not in watchlist, add it and switch button back to check
            userService.addToWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    
                    // Add ticker symbol to self.watchlistStocks
                    self.watchlistStocks.append(self.stockTickerString)
                    
                    // Update button and tableView
                    self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
                    self.tableView.reloadData()
                }
            })
            
        }
        
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        activityIndicator.startSpinner(viewcontroller: self)
        
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
                    
                    if let newDict = responseJSON {
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        
                        self.activityIndicator.stopSpinner()
                    }
                }
            })
        case 2:
            timeSelect = "3m";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    
                    if let newDict = responseJSON {
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        
                        self.activityIndicator.stopSpinner()
                    }
                    
                }
            })
            
        case 3:
            timeSelect = "1y";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    
                    if let newDict = responseJSON {
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        
                        self.activityIndicator.stopSpinner()
                    }
                }
            })
            
        case 4:
            timeSelect = "5y";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    
                    if let newDict = responseJSON {
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        
                        self.activityIndicator.stopSpinner()
                    }
                    
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
            
            return cell
        } else {
            return SimilarStockCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let stockItemTicker = similarStocks[indexPath.row].ticker
            let stockItemCompany = similarStocks[indexPath.row].company
            self.selectedStockSymbol = stockItemTicker
            self.selectedStockCompany = stockItemCompany
            performSegue(withIdentifier: "stockInfoToPopUp", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

// Extension for the modal slide dismissal
extension StockInfoVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return modalSlideInteractor.hasStarted ? modalSlideInteractor : nil
    }
}
