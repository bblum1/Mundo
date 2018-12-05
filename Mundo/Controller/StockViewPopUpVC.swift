//
//  StockViewPopUpVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 12/4/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit

class StockViewPopUpVC: UIViewController {
    
    var modalSlideInteractor:ModalSlideInteractor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //showHelperCircle()
    }
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        print("HANDLING GESTURE!!!")
        let percentThreshold: CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let modalSlideInteractor = modalSlideInteractor else { return }
        
        print("Got beyond guard")
        switch sender.state {
        case .began:
            print("BEGINNING SLIDE")
            modalSlideInteractor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            modalSlideInteractor.shouldFinish = progress > percentThreshold
            modalSlideInteractor.update(progress)
        case .cancelled:
            modalSlideInteractor.hasStarted = false
            modalSlideInteractor.cancel()
        case .ended:
            modalSlideInteractor.hasStarted = false
            modalSlideInteractor.shouldFinish
                ? modalSlideInteractor.finish()
                : modalSlideInteractor.cancel()
        default:
            break
        }
    }
    
    /*func showHelperCircle(){
        let center = CGPoint(x: view.bounds.width * 0.5, y: 100)
        let small = CGSize(width: 30, height: 30)
        let circle = UIView(frame: CGRect(origin: center, size: small))
        circle.layer.cornerRadius = circle.frame.width/2
        circle.backgroundColor = UIColor.white
        circle.layer.shadowOpacity = 0.8
        circle.layer.shadowOffset = CGSize()
        view.addSubview(circle)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [],
            animations: {
                circle.frame.origin.y += 200
                circle.layer.opacity = 0
        },
            completion: { _ in
                circle.removeFromSuperview()
        }
        )
    }
    */
    
}
