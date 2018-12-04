//
//  SimilarStockCell.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/1/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

protocol SimilarStockDelegate: class {
    func didTapCell(_ cell: SimilarStockCell)
}

class SimilarStockCell: UITableViewCell {
    
    weak var delegate: SimilarStockDelegate?
    
    var stock: SimilarStockItem!
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell (stock: SimilarStockItem) {
        
        self.stock = stock
        
        // set the labels in the cell
        self.tickerLabel.text = stock.ticker
        self.companyLabel.text = stock.company
        self.priceButton.setTitle("\(stock.latestPrice)", for: .normal)
        
        // check if price is down and assign color accordingly
        let openingPrice = Float(0.00)
        
        self.priceButton.setTitleColor(UIColor.white, for: .normal)
        
        if stock.latestPrice < openingPrice {
            priceButton.backgroundColor = UIColor(red: 244/255, green: 85/255, blue: 50/255, alpha: 1.0)
        } else {
            priceButton.backgroundColor = UIColor(red: 29/255, green: 206/255, blue: 151/255, alpha: 1.0)
        }
    }

}
