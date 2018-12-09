//
//  StockViewPopUpVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit
import Highcharts

class StockViewPopUpVC: UIViewController {
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    
    var stockTickerString = ""
    var companyString = ""
    @IBOutlet weak var companyAndProductView: CompanyAndProductView!
    @IBOutlet weak var statsView: StatsView!
    @IBOutlet weak var companyDescriptionView: CompanyDescriptionView!
    
    @IBOutlet weak var segmentedControlButton: UISegmentedControl!
    
    let currUserEmail = "btrossen@nd.edu"
    
    var activityIndicator = ActivitySpinnerClass()
    
    var modalSlideInteractor: ModalSlideInteractor? = nil
    
    // Use this class to make calls with a stock symbol and range of chart data
    var stockInfoService = StockInfoService()
    
    // Use this class to make calls to functions related to user and watchlist
    var userService = UserService()
    
    var fundamentalsService = FundamentalsService()
    
    // Use this class as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    var chartView: HIChartView!
    
    var watchlistStocks: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarView.layer.cornerRadius = 12.0
        topBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        activityIndicator.startSpinner(viewcontroller: self)
        
        print("LOADING POPUP NOW...... with \(stockTickerString) and \(String(describing: modalSlideInteractor)) and \(companyString)")
        
        if self.watchlistStocks.contains(self.stockTickerString) {
            // Already in watchlist, set as checkmark
            self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
        } else {
            // Not in watchlist, make it a plus
            self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
        }
        
        // Load the chart for the stock that was scanned
        stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
            print("LOADING THE STOCK TICKER: \(self.stockTickerString)")
            DispatchQueue.main.async {
                
                // Load the scannedStockItem object with return item
                if let responseDict = responseJSON {
                    
                    self.scannedStockItem = ScannedStockItem(stockItemDict: responseDict)
                    
                    // Load main stock view using Highcharts
                    self.loadChartView()
                }
                self.activityIndicator.stopSpinner()
            }
        })
        
        loadAllSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func loadAllSubviews() {
        //Load the Robinhood Fundamentals Data from the Robinhood API and FundamentalsInfoService file.
        print("LOADING ALL THE SUBVIEWS WITH: \(stockTickerString)")
        fundamentalsService.callFundamentalsData(ticker: stockTickerString, completionHandler: {(responseDict, error) in
            print("response dict: \(String(describing: responseDict))")
            
            if let parseDict = responseDict {
                print("PARSEDATA:::::\(parseDict)")
                // set all the views after Robinhood fundamentals call
                self.companyAndProductView.setCompanyAndProductView(brandName: "", companyName: self.companyString, productName: "", parseDict: parseDict)
                
                self.statsView.setStatsView(parseDict: parseDict)
                
                self.companyDescriptionView.setCompanyDetailsView(parseDict: parseDict)
            }
            
        })
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
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let modalSlider = modalSlideInteractor else { return }
        
        switch sender.state {
        case .began:
            modalSlider.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            modalSlider.shouldFinish = progress > percentThreshold
            modalSlider.update(progress)
        case .cancelled:
            modalSlider.hasStarted = false
            modalSlider.cancel()
        case .ended:
            modalSlider.hasStarted = false
            modalSlider.shouldFinish
                ? modalSlider.finish()
                : modalSlider.cancel()
        default:
            break
        }
    }
    
    @IBAction func watchlistButtonTapped(_ sender: Any) {
        if self.watchlistStocks.contains(self.stockTickerString) {
            
            // Already in watchlist, remove it and switch button back to plus
            userService.removeFromWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    
                    // Remove ticker symbol from self.watchlistStocks
                    if let itemToRemoveIndex = self.watchlistStocks.index(of: self.stockTickerString) {
                        self.watchlistStocks.remove(at: itemToRemoveIndex)
                    }
                    
                    // Update button
                    self.addToWatchlistButton.setImage(UIImage(named: "plus-add-button"), for: .normal)
                }
            })
            
        } else {
            
            // Not in watchlist, add it and switch button back to check
            userService.addToWatchlist(email: currUserEmail, symbol: stockTickerString, completionHandler: {(responseString, error) in
                DispatchQueue.main.async {
                    
                    // Add ticker symbol to self.watchlistStocks
                    self.watchlistStocks.append(self.stockTickerString)
                    
                    // Update button
                    self.addToWatchlistButton.setImage(UIImage(named: "check-added-button"), for: .normal)
                }
            })
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        activityIndicator.startSpinner(viewcontroller: self)
        
        var timeSelect = "1d"
        switch segmentedControlButton.selectedSegmentIndex
        {
        case 0:
            timeSelect = "1d";
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
                    if let newDict = responseJSON {
                        self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                        
                        // Load main stock view using Highcharts
                        self.loadChartView()
                        
                        self.activityIndicator.stopSpinner()
                    }
                }
            })
        case 1:
            timeSelect = "1m"
            stockInfoService.callChartData(ticker: stockTickerString, range: timeSelect, completionHandler: {(responseJSON, error) in
                
                DispatchQueue.main.async {
                    // Load the scannedStockItem object with return item
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
                    // Load the scannedStockItem object with return item
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
                    // Load the scannedStockItem object with return item
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
                    // Load the scannedStockItem object with return item
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
