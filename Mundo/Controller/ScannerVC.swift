//
//  ScannerVC.swift
//  Mundo
//
//  Created by Horacio Lopez on 10/28/18.
//  Copyright © 2018 GiveBee, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var square: UIImageView!
    
    let barcodeService = BarcodeService()
    
    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.dataMatrix]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            if captureDevice != nil {
                // Get the instance of the AVCaptureDeviceInput class using the previosu device object
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                
                // Set the input device on the capture session
                self.session.addInput(input)
            } else {
                let noCameraAlert = UIAlertController(title: "Unable to Read Barcode", message: "Please try again.", preferredStyle: .alert)
                noCameraAlert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                
                present(noCameraAlert, animated: true, completion: nil)
            }
        }
        catch {
            print("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = supportedCodeTypes
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        self.view.bringSubviewToFront(square)
        
        session.startRunning()
        
        // Optional code to change the rect if detected a code
        /*if let barcodeFrameView = barcodeFrameView {
            barcodeFrameView.layer.borderColor = UIColor.purple.cgColor
            barcodeFrameView.layer.borderWidth = 5
            view.addSubview(barcodeFrameView)
            view.bringSubview(toFront: barcodeFrameView)
        }*/
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("IN THE FUNC")
        if metadataObjects.count > 0
        {
         print("NEXT LEVEL")
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if supportedCodeTypes.contains(object.type)
                {
                    // this is the final step where string val exists
                    if let barcodeString = object.stringValue {
                        print("THE STRING", barcodeString)
                        barcodeService.makeBarcodeCall(gtin: barcodeString)
                        let barcodeStringAlert = UIAlertController(title: "Barcode scanned!", message: barcodeString, preferredStyle: .alert)
                        barcodeStringAlert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                        present(barcodeStringAlert, animated: true, completion: nil)
                    } else {
                        print("ERROR")
                    }
                }
            } else {
                let unreadableBarcodeAlert = UIAlertController(title: "Unable to Read Barcode", message: "Please try again.", preferredStyle: .alert)
                unreadableBarcodeAlert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                
                present(unreadableBarcodeAlert, animated: true, completion: nil)
            }
        } else {
            print("ERROR IN READING QR")
        }
    }
    
    // Object functions
    
    @IBAction func backBttnTapped(_ sender: Any) {
        performSegue(withIdentifier: "scannerToFirstPage", sender: nil)
    }
    
}
