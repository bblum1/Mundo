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
    var scannedProductString = ""
    
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
                newDict["brand"] = self.scannedBrandString.localizedCapitalized
                
                self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                
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
        self.productNameLabel.text = self.scannedProductString
        
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.zoomType = "x"
        
        let title = HITitle()
        title.text = scannedStockItem.ticker
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        options.title = title
        options.subtitle = subtitle
        
        let xAxis = HIXAxis()
        xAxis.type = "datetime"
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        options.yAxis = [yAxis]
        
        let legend = HILegend()
        legend.enabled = 0
        
        let plotOptions = HIPlotOptions()
        plotOptions.area = HIArea()
        plotOptions.area.fillColor = HIColor(linearGradient: ["x1": 0, "x2": 0, "y1": 0, "y2": 1], stops: [[0, "rgb(47,126,216)"], [1, "rgba(47,126,216,0)"]])
        
        plotOptions.area.marker = HIMarker()
        plotOptions.area.marker.radius = 2
        plotOptions.area.lineWidth = 1
        
        let state = HIStates()
        state.hover = HIHover()
        state.hover.lineWidth = 1
        plotOptions.area.states = state
        
        let area = HIArea()
        area.name = "\(stockTickerString) Stock Data"
        print("BOUT TO ADD: \(scannedStockItem.chartPrices)")
        area.data = scannedStockItem.chartPrices
        
        options.chart = chart
        options.plotOptions = plotOptions
        options.series = [area]
        
        self.chartView.options = options
        self.stockView.addSubview(self.chartView)
    }
    
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
}
