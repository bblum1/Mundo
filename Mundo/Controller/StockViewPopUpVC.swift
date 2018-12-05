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
    
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    
    var stockTickerString = ""
    @IBOutlet weak var companyNameLabel: UILabel!
    
    let currUserEmail = "btrossen@nd.edu"
    
    var activityIndicator = ActivitySpinnerClass()
    
    var modalSlideInteractor: ModalSlideInteractor? = nil
    
    // Use this class to make calls with a stock symbol and range of chart data
    var stockInfoService = StockInfoService()
    
    // Use this class to make calls to functions related to user and watchlist
    var userService = UserService()
    
    // Use this class as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    var chartView: HIChartView!
    
    @IBOutlet weak var segmentedControlButton: UISegmentedControl!
    
    var watchlistStocks: [String] = []
    
    var savedTicker = ""
    var savedModalSlideInteractor: ModalSlideInteractor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startSpinner(viewcontroller: self)
        
        print("LOADING POPUP NOW...... with \(stockTickerString) and \(modalSlideInteractor)")
        
        if modalSlideInteractor != nil {
            print("saving MODAL with val = \(modalSlideInteractor)")
            self.savedModalSlideInteractor = self.modalSlideInteractor
            self.savedTicker = self.stockTickerString
        }
        print("TRY AGAIN NOW....... with \(savedTicker) and \(savedModalSlideInteractor)")
        
        
        
        userService.loadUserWatchlist(email: currUserEmail, completionHandler: {(responseArray, error) in
            print("GOT THE USER STOCKS: \(String(describing: responseArray))")
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func saveItems(ticker: String, modalSlider: ModalSlideInteractor) {
        self.savedTicker = ticker
        self.savedModalSlideInteractor = modalSlider
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
        
        self.companyNameLabel.text = self.scannedStockItem.company
        
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
        //plotoptions.series.color = "#CB92EF"
        
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
        print("HANDLING GESTURE!!!")
        let percentThreshold: CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        print("About to see if we fit in")
        guard let modalSlider = savedModalSlideInteractor else { return }
        print("PROGRESS: \(progress)")
        
        switch sender.state {
        case .began:
            print("GOT BEGINNING SLIDE")
            modalSlider.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            print("GOT CHANGED")
            modalSlider.shouldFinish = progress > percentThreshold
            modalSlider.update(progress)
        case .cancelled:
            print("GOT CANCELLED")
            modalSlider.hasStarted = false
            modalSlider.cancel()
        case .ended:
            print("GOT ENDED")
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
    
}
