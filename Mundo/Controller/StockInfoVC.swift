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
    
    var activityIndicator = ActivitySpinnerClass()
    
    // Use this class to make calls with a stock symbol and range of chart data
    var stockInfoService = StockInfoService()
    
    // Use this object as the overall class item to store the data
    var scannedStockItem: ScannedStockItem!
    
    // String data is passed from previous view controller
    var stockTickerString = ""
    var scannedBrandString = ""
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var stockTickerLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var stockView: UIView!
    var chartView: HIChartView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BOUT TO LOAD UP AND MAKE CALL WITH: \(stockTickerString)")
        
        // Begin loading the view with the API call
        activityIndicator.startSpinner(viewcontroller: self)
        
        stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
            print("FINAL STEP IS HERE:::::: \(responseJSON)")
            
            DispatchQueue.main.async {
                // Load the scannedStockItem object with return item
                var newDict = responseJSON!
                newDict["brand"] = self.scannedBrandString
                
                self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                
                print("With StockItem: \(self.scannedStockItem.chartPrices)")
                
                // Load main stock view using Highcharts
                self.loadChartView()
                
                self.activityIndicator.stopSpinner()
            }
        })
        
    }
    
    func loadChartView() {
        self.companyNameLabel.text = self.scannedStockItem.company
        self.stockTickerLabel.text = self.scannedStockItem.ticker
        self.brandNameLabel.text = self.scannedStockItem.brand
        
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "spline"
        options.chart = chart
        
        let title = HITitle()
        title.text = scannedStockItem.ticker
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        options.title = title
        options.subtitle = subtitle
        
        let plotOptions = HIPlotOptions()
        plotOptions.spline = HISpline()
        options.plotOptions = plotOptions
        
        let line = HISpline()
        line.data = scannedStockItem.chartPrices
        
        self.chartView.options = options
    }
    
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
}
