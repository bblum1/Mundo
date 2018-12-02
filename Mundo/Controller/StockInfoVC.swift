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
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var stockView: UIView!
    var chartView: HIChartView!
    
    var industryString = ""
    
    @IBOutlet weak var tableView: UITableView!
    var similarStockService = SimilarStockService()
    var similarStocks = [SimilarStockItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startSpinner(viewcontroller: self)
        
        // Load the chart for the stock that was scanned
        stockInfoService.callChartData(ticker: stockTickerString, range: "1d", completionHandler: {(responseJSON, error) in
            
            DispatchQueue.main.async {
                
                // Load the scannedStockItem object with return item
                var newDict = responseJSON!
                newDict["brand"] = self.scannedBrandString.localizedCapitalized
                
                self.scannedStockItem = ScannedStockItem(stockItemDict: newDict)
                
                //print("With StockItem: \(self.scannedStockItem.chartPrices)")
                
                // Load main stock view using Highcharts
                self.loadChartView()
                
                self.activityIndicator.stopSpinner()
            }
        })
        
        // Set tableView of top 5 stocks in the same industry
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 254/255, green: 255/255, blue: 240/255, alpha: 1.00)
        
        // Assign the table data
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
        //xaxis.title = HITitle()
        xaxis.labels = HILabels()
        xaxis.labels.enabled = false
        //xaxis.title.text = "Time"
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
        stockView.addSubview(chartView)
    }
    
    @IBAction func backBttn(_ sender: Any) {
        performSegue(withIdentifier: "stockBackToScanner", sender: nil)
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
}

extension StockInfoVC: SimilarStockDelegate {
    
    func didTapCell(_ cell: SimilarStockCell) {
        // Initiate refreshing of the view with whatever cell user tapped
        
    }
}
