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
    var barcodeService: BarcodeService!
    
    var scannedStockItem = ScannedStockItem()
    
    var gtinString = ""
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var stockTickerLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var stockView: UIView!
    var chartView: HIChartView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BOUT TO LOAD UP")
        // Begin loading the view with the API call
        activityIndicator.startSpinner(viewcontroller: self)
        
        print("Beginning the API Calls")
        // TODO: Fix the timing here
        scannedStockItem = barcodeService.makeBarcodeCall(gtin: gtinString)
        
        activityIndicator.stopSpinner()
        
        // Load main stock view using Highcharts
        self.loadChartView()
    }
    
    func loadChartView() {
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
