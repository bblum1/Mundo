//
//  ProfileAccountVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/3/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class ProfileAccountVC: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stockView: UIView!
    
    @IBOutlet weak var segmentedChartButton: UISegmentedControl!
    
    @IBOutlet weak var watchlistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("THE SIZE OF MAIN VIEW IS: \(mainView.frame.width) x \(mainView.frame.height)")
    }

}
