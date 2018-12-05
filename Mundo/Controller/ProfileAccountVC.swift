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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChartView()

        // Do any additional setup after loading the view.
        print("THE SIZE OF MAIN VIEW IS: \(mainView.frame.width) x \(mainView.frame.height)")
    }
    
    func loadChartView() {
        let chartView = HIChartView(frame: stockView.bounds)
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.plotBackgroundColor = HIColor()
        chart.plotBorderWidth = NSNumber()
        chart.plotShadow = 0
        chart.type = "pie"
        
        let title = HITitle()
        title.text = "Watchlist Diversity"
        
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
        pie.data = [["name": "Microsoft Internet Explorer", "y": 56.33], ["name": "Chrome", "y": 24.03, "sliced": 1, "selected": 1], ["name": "Firefox", "y": 10.38], ["name": "Safari", "y": 4.77], ["name": "Opera", "y": 0.91], ["name": "Proprietary or Undetectable", "y": 0.2]]
        
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
