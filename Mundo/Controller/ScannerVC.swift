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
    
    var activityIndicator = ActivitySpinnerClass()
    
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
        //captureDevice?.flashMode = .auto
        
        do {
            if captureDevice != nil {
                
                // Get the instance of the AVCaptureDeviceInput class using the previosu device object
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                
                // TODO: Allow flash if needed with the auto features
                //let flashSettings = getCameraSettings(camera: captureDevice!)
                
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
    }
    
    // variables that will be prepared and sent in segue
    private var stockTicker = ""
    private var stockBrand = ""
    private var scannedProduct = ""
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if supportedCodeTypes.contains(object.type)
                {
                    // this is the final step where string val exists
                    if let barcodeString = object.stringValue {
                        print("THE STRING \(barcodeString)")
                        
                        // stop capture session after successful scan
                        session.stopRunning()
                        activityIndicator.startSpinner(viewcontroller: self)
                        
                        // TODO: UNCOMMENT/COMMENT DEPENDING ON IF YOU ARE TESTING OR NOT
                        //barcodeService.makeBarcodeCall(gtin: "018200150470", completionHandler: {(returnArray, error) in
                        barcodeService.makePaidBarcodeCall(currViewController: self, gtin: barcodeString, completionHandler: {(returnArray, error) in
                            
                            if let brandAndDetails = returnArray {
                                self.stockBrand = brandAndDetails[0].localizedCapitalized
                                self.stockTicker = brandAndDetails[1]
                                self.scannedProduct = brandAndDetails[2]
                            }
                            
                            DispatchQueue.main.async {
                                self.activityIndicator.stopSpinner()
                                self.performSegue(withIdentifier: "scannerToStockInfo", sender: nil)
                            }
                            
                        })
                        
                    } else {
                        print("ERROR")
                    }
                }
            } else {
                
                // stop unnecessary captures even on failure
                session.stopRunning()
                
                let unreadableBarcodeAlert = UIAlertController(title: "Unable to Read Barcode", message: "Please try again.", preferredStyle: .alert)
                unreadableBarcodeAlert.addAction(UIAlertAction(title: "Retake", style: .default, handler: { (action) in
                    self.reRunSession()
                    unreadableBarcodeAlert.dismiss(animated: true, completion: nil)
                }))
                
                present(unreadableBarcodeAlert, animated: true, completion: nil)
            }
        } else {
            print("ERROR IN READING QR")
        }
    }
    
    func reRunSession() {
        session.startRunning()
    }
    
    // Prepare to transfer returned stock after scan to StockInfoVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? StockInfoVC
        viewController?.stockTickerString = self.stockTicker
        viewController?.scannedBrandString = self.stockBrand
        viewController?.scannedProductString = self.scannedProduct
    }
    
    // Camera function attempting to get flash to work
    func getCameraSettings(camera: AVCaptureDevice) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        
        if camera.hasFlash {
            settings.flashMode = .auto
        }
        
        return settings
    }
    
}
