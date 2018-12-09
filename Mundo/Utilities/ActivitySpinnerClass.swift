//
//  ActivitySpinnerClass.swift
//  Mundo
//
//  Created by Horacio Lopez on 11/25/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import Foundation
import UIKit

class ActivitySpinnerClass: UIActivityIndicatorView {
    
    func startSpinner(viewcontroller: UIViewController) {
        self.center = viewcontroller.view.center
        self.hidesWhenStopped = true
        self.style = UIActivityIndicatorView.Style.gray
        viewcontroller.view.addSubview(self)
        
        self.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopSpinner() {
        self.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
}
