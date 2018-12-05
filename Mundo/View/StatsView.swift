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
        
        DispatchQueue.main.async {
            // col 1
            //self.openLabel.text = parseDict["open"] as? String
            if let openString = parseDict["open"] as? String {
                let openFloat = Float(openString) ?? 0.00
                self.openLabel.text = String(format: "$%.2f", openFloat)
            }
            
            if let highString = parseDict["high"] as? String {
                let highFloat = Float(highString) ?? 0.00
                self.highLabel.text = String(format: "$%.2f", highFloat)
            }
            
            if let lowString = parseDict["low"] as? String {
                let lowFloat = Float(lowString) ?? 0.00
                self.lowLabel.text = String(format: "$%.2f", lowFloat)
            }
            
            if let high52String = parseDict["high_52_weeks"] as? String {
                let high52Float = Float(high52String) ?? 0.00
                self.high52Label.text = String(format: "$%.2f", high52Float)
            }
            
            if let low52String = parseDict["low_52_weeks"] as? String {
                let low52Float = Float(low52String) ?? 0.00
                self.low52Label.text = String(format: "$%.2f", low52Float)
            }
            
            // col 2
            let volumeString = parseDict["volume"] as! String
            self.volumeLabel.text = self.createSuffix(num: volumeString)
            let avgVolumeString = parseDict["average_volume"] as! String
            self.averageVolumeLabel.text = self.createSuffix(num: avgVolumeString)
            let marketString = parseDict["market_cap"] as! String
            self.marketCapLabel.text = self.createSuffix(num: marketString)
            if let peString = parseDict["pe_ratio"] as? String {
                let peFloat = Float(peString) ?? 0.00
                self.pe_ratioLabel.text = String(format: "$%.2f", peFloat)
            }
            if let divString = parseDict["dividend_yield"] as? String {
                let divFloat = Float(divString) ?? 0.00
                self.div_yieldLabel.text = String(format: "$%.2f", divFloat)
            }
            
        }
        
    }
    
    func createSuffix(num: String) -> String {
        let floatNum = Float(num)
        if let number = floatNum as NSNumber? {
            var num:Double = number.doubleValue
            let sign = ((num < 0) ? "-" : "")
            num = fabs(num)
            if (num < 1000.0) {
                return "\(sign)\(num)"
            }
            let exp:Int = Int(log10(num) / 3.0)
            let units:[String] = ["K", "M", "B", "T", "Q", "P"]
            let roundedNum:Double = round(100 * num / pow(1000.0, Double(exp))) / 100
            
            return "\(sign)\(roundedNum)\(units[exp-1])"
        } else {
            return ""
        }
        
    }

}
