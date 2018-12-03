//
//  WatchlistCell.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/3/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

protocol WatchlistCellDelegate: class {
    func didTapCell(_ cell: WatchlistCell)
}

class WatchlistCell: UITableViewCell {
    
    weak var delegate: WatchlistCellDelegate?
    
    var watchlistStock: WatchlistItem!
    
    @IBOutlet weak var tickerLabel: UILabel!
    // @IBOutlet weak var miniStockView: UIView!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell (stock: WatchlistItem) {
        
        self.watchlistStock = stock
        
        // set the labels in the cell
        self.tickerLabel.text = stock.ticker
        self.companyLabel.text = stock.company
        self.priceButton.setTitle("\(stock.latestPrice)", for: .normal)
        
        // check if price is down and assign color accordingly
        let openingPrice = Float(0.00)
        
        if stock.latestPrice < openingPrice {
            priceButton.backgroundColor = UIColor.red
        } else {
            priceButton.backgroundColor = UIColor.green
        }
    }
    
}
