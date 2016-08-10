//
//  ViewController.swift
//  QR Blank
//
//  Created by Ka Ho on 27/6/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import PKHUD

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scanButton, closeButton: UIButton!
    @IBOutlet weak var googleSafeBrowsing, autoOpenURL: UISwitch!

    let googleAPIKey = "Your Google API key here"
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.layer.cornerRadius = 5
    }

    @IBAction func qrCodeScanAction(sender: AnyObject) {
        startCapture()
    }
    
    @IBAction func dimissScanAction(sender: AnyObject) {
        stopCapture()
    }
    
    func startCapture() {
        do {
            let videoInput = try AVCaptureDeviceInput(device: AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))
            captureSession.addInput(videoInput)
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            view.layer.addSublayer(previewLayer)
            view.bringSubviewToFront(closeButton)
            closeButton.hidden = false
            captureSession.startRunning()
        } catch {
        }
    }
    
    func stopCapture() {
        captureSession.stopRunning()
        captureSession = AVCaptureSession()
        previewLayer.removeFromSuperlayer()
        closeButton.hidden = true
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            if qrCodeFormatValid(readableObject.stringValue) {
                stopCapture()
                urlCheck(readableObject.stringValue)
            } else {
                HUD.flash(.LabeledError(title: "Error", subtitle: "Invalid url format!"))
            }
        }
    }
    
    func checkURLSafe(url:String, completion:(result: Bool) -> Void) {
        HUD.show(.LabeledProgress(title: "Safety Check", subtitle: "Identifying..."))
        let client = ["clientId":"qr-blank", "clientVersion":"1.0"]
        let threatTypes = ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "THREAT_TYPE_UNSPECIFIED"]
        let platformTypes = ["ANY_PLATFORM"]
        let threatEntryTypes = ["URL"]
        let threatEntries = [["url":"\(url)"]]
        let threatInfo = ["threatTypes":threatTypes, "platformTypes":platformTypes, "threatEntryTypes":threatEntryTypes, "threatEntries":threatEntries]
        let paras:[String:AnyObject] = ["client":client, "threatInfo":threatInfo]
        Alamofire.request(.POST, "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=\(googleAPIKey)", parameters: paras, encoding: .JSON).responseJSON { (response) in
            let result = JSON(response.result.value!).count == 0
            HUD.flash(result ? .LabeledSuccess(title: "Passed", subtitle: "The url look safe") : .LabeledError(title: "Failed", subtitle: "The url look dangerous"), delay: 1.0, completion: { (true) in
                completion(result: result)
            })
            
        }
    }
    
    func qrCodeFormatValid(source:String) -> Bool {
        if let url = NSURL(string: source) {
            return UIApplication.sharedApplication().canOpenURL(url)
        }
        return false
    }
    
    func goToURL(url:String) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func urlCheck(url:String) {
        func goOption(noPrompt:Bool, safeCheckPassed:Bool = true) {
            if noPrompt {
                goToURL(url)
            } else {
                promptAlert(url, safeCheckPassed: safeCheckPassed)
            }
        }
        if googleSafeBrowsing.on {
            checkURLSafe(url, completion: { (result) in
                goOption(self.autoOpenURL.on && result, safeCheckPassed: result)
            })
        } else {
            goOption(autoOpenURL.on)
        }
    }
    
    func promptAlert(url:String, safeCheckPassed:Bool) {
        let alertController = UIAlertController(title: "Confirm to go?", message: "\(url)\(safeCheckPassed ? "\(googleSafeBrowsing.on ? "\n\nThis url is considered as safe in Google Safe Browsing" : "")" : "\n\nWarning: This url is NOT considered as safe in Google Safe Browsing")", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Go", style: (safeCheckPassed ? .Default : .Destructive)) { (action) in
            self.goToURL(url)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

