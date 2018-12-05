//
//  StatsView.swift
//  Mundo
//
//  Created by Bailey Blum on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class StatsView: UIView {
    
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var high52Label: UILabel!
    @IBOutlet weak var low52Label: UILabel!
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var averageVolumeLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var pe_ratioLabel: UILabel!
    @IBOutlet weak var div_yieldLabel: UILabel!
    

    // Financial Info
    func setStatsView(parseDict: Dictionary<String, Any>) {
        // col 1
        self.openLabel.text = parseDict["open"] as? String
        self.highLabel.text = parseDict["high"] as? String
        self.lowLabel.text = parseDict["low"] as? String
        self.high52Label.text = parseDict["high_52_weeks"] as? String
        self.low52Label.text = parseDict["low_52_weeks"] as? String
        
        // col 2
        self.volumeLabel.text = parseDict["volume"] as? String
        self.averageVolumeLabel.text = parseDict["average_volume"] as? String
        self.marketCapLabel.text = parseDict["market_cap"] as? String
        self.pe_ratioLabel.text = parseDict["pe_ratio"] as? String
        self.div_yieldLabel.text = parseDict["dividend_yield"] as? String
    }
    
    
    
    

}
