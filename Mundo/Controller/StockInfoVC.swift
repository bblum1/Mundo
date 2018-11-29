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
                
                print("With StockItem: \(self.scannedStockItem.chartPrices)")
                
                // Load main stock view using Highcharts
                self.loadChartView()
                
                self.activityIndicator.stopSpinner()
            }
        })
        
    }
    
    /*func loadChartView() {
        
        self.companyNameLabel.text = self.scannedStockItem.company
        self.stockTickerLabel.text = self.scannedStockItem.ticker
        self.brandNameLabel.text = self.scannedStockItem.brand
        self.productNameLabel.text = self.scannedProductString
        
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
    } */
    
    /*func loadChartView() {
        
        self.companyNameLabel.text = self.scannedStockItem.company
        self.stockTickerLabel.text = self.scannedStockItem.ticker
        self.brandNameLabel.text = self.scannedStockItem.brand
        self.productNameLabel.text = self.scannedProductString
        
        super.viewDidLoad()
        
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
    
        let title = HITitle()
        title.text = scannedStockItem.ticker
        
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        
        let yaxis = HIYAxis()
        yaxis.title = HITitle()
        yaxis.title.text = "Price"
        
        let line1 = HILine()
        line1.data = scannedStockItem.chartPrices
        
        let responsive = HIResponsive()
        
        let rules1 = HIRules()
        rules1.condition = HICondition()
        rules1.condition.maxWidth = 500
        responsive.rules = [rules1]
        
        options.title = title
        options.yAxis = [yaxis]
        options.responsive = responsive
        
        chartView.options = options
        
        view.addSubview(chartView)
    } */
    
    func loadChartView() {
        
        var dataset:[(time: String, price: Float)] = []
        
        
        let times = scannedStockItem.chartLabels
        let prices = scannedStockItem.chartPrices
        var counter = 0
        for _ in times {
            dataset.append((time: times[counter], price: prices[counter]))
            counter = counter + 1
        }
        
        print(dataset)
        
        
        let priceList = prices.filter() {
            $0 > 0
        }
        
        
        self.companyNameLabel.text = self.scannedStockItem.company
        self.stockTickerLabel.text = self.scannedStockItem.ticker
        self.brandNameLabel.text = self.scannedStockItem.brand
        self.productNameLabel.text = self.scannedProductString
        
        super.viewDidLoad()
        
        self.chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        
        let title = HITitle()
        title.text = scannedStockItem.ticker
        title.style?.fontWeight = "bold"
        title.style?.fontSize = "30px"
        title.style?.color = "#333333"
        
        let subtitle = HISubtitle()
        subtitle.text = scannedStockItem.company
        
        let yaxis = HIYAxis()
        //yaxis.labels.format =
        yaxis.title = HITitle()
        yaxis.title.text = "Price"
        
        let xaxis = HIXAxis()
        xaxis.title = HITitle()
        xaxis.labels = HILabels()
        xaxis.labels.enabled = false
        xaxis.title.text = "Time"
        let date = xaxis.dateTimeLabelFormats
        date?.hour = "%I %p"
        date?.minute = "%I:%M %p"
        
        //let legend = HILegend()
        //legend.layout = "vertical"
        //legend.align = "right"
        //legend.verticalAlign = "middle"
        
        let plotoptions = HIPlotOptions()
        plotoptions.series = HISeries()
        //plotoptions.series.label = HILabel()
        //plotoptions.series.label.connectorAllowed = 0
        //plotoptions.series.pointStart = 1
        
        let line1 = HILine()
        line1.name = scannedStockItem.ticker + " Stock Price"
        line1.data = priceList
        
        let responsive = HIResponsive()
        
        let rules1 = HIRules()
        rules1.condition = HICondition()
        rules1.condition.maxWidth = 500
        //rules1.chartOptions = ["legend": ["layout": "horizontal", "align": "center", "verticalAlign": "bottom"]]
        responsive.rules = [rules1]
        
        let exporting = HIExporting()
        exporting.enabled = false
        
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
        options.tooltip = tooltip
        options.responsive = responsive
        options.plotOptions = plotoptions
        options.exporting = exporting
        
        chartView.options = options
        
        view.addSubview(chartView)
    }
    
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
    }
    
}
