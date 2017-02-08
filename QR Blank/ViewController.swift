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
    @IBOutlet weak var launchAtStart, googleSafeBrowsing, autoOpenURL: UISwitch!

    let googleAPIKey = "AIzaSyDiizUkubGEdRZ2LCLPlmlwPJJhIbCe0_Q"
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var initialLaunch:Bool = true
    var requestForCapture:Bool = false
    var internetDown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.layer.cornerRadius = 5
        
        setInitialSwitchOptions()
        prepareCapture()
        
        if launchAtStart.isOn && initialLaunch {
            showFromCapture()
            initialLaunch = false
        }
    }

    @IBAction func qrCodeScanAction(_ sender: AnyObject) {
        showFromCapture()
    }
    
    @IBAction func dimissScanAction(_ sender: AnyObject) {
        hideFromCapture()
    }
    
    func prepareCapture() {
        do {
            let videoInput = try AVCaptureDeviceInput(device: AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo))
            captureSession.addInput(videoInput)
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            captureSession.startRunning()
        } catch {
        }
    }
    
    func showFromCapture() {
        requestForCapture = true
        view.layer.addSublayer(previewLayer)
        view.bringSubview(toFront: closeButton)
        closeButton.isHidden = false
    }
    
    func hideFromCapture() {
        previewLayer.removeFromSuperlayer()
        closeButton.isHidden = true
        requestForCapture = false
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if requestForCapture {
            if let metadataObject = metadataObjects.first {
                hideFromCapture()
                let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
                if qrCodeFormatValid(readableObject.stringValue) {
                    urlCheck(readableObject.stringValue)
                } else {
                    nonURLAlert(readableObject.stringValue)
                }
            }
        }
    }
    
    func checkURLSafe(_ url:String, completion:@escaping (_ result: Bool) -> Void) {
        HUD.show(.labeledProgress(title: "Safety Check", subtitle: "Identifying..."))
        let client = ["clientId":"qr-blank", "clientVersion":"1.0"]
        let threatTypes = ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "THREAT_TYPE_UNSPECIFIED"]
        let platformTypes = ["ANY_PLATFORM"]
        let threatEntryTypes = ["URL"]
        let threatEntries = [["url":"\(url)"]]
        let threatInfo = ["threatTypes":threatTypes, "platformTypes":platformTypes, "threatEntryTypes":threatEntryTypes, "threatEntries":threatEntries] as [String : Any]
        let paras:[String:AnyObject] = ["client":client as AnyObject, "threatInfo":threatInfo as AnyObject]
        Alamofire.request("https://safebrowsing.googleapis.com/v4/threatMatches:find?key=\(googleAPIKey)", method: .post, parameters: paras, encoding: JSONEncoding.default).responseJSON { (response) in
            self.internetDown = response.result.isFailure
            if self.internetDown {
                HUD.hide()
                completion(false)
            } else {
                let result = JSON(response.result.value!).count == 0
                HUD.flash(result ? .labeledSuccess(title: "Passed", subtitle: "The url look safe") : .labeledError(title: "Failed", subtitle: "The url look dangerous"), delay: 1.0, completion: { (true) in
                    completion(result)
                })
            }
        }
    }
    
    func qrCodeFormatValid(_ source:String) -> Bool {
        if let url = URL(string: source) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func goToURL(_ url:String) {
        UIApplication.shared.openURL(URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!)
    }
    
    func urlCheck(_ url:String) {
        func goOption(_ noPrompt:Bool, safeCheckPassed:Bool = true) {
            if noPrompt {
                goToURL(url)
            } else {
                promptAlert(url, safeCheckPassed: safeCheckPassed)
            }
        }
        if googleSafeBrowsing.isOn {
            checkURLSafe(url, completion: { (result) in
                goOption(self.autoOpenURL.isOn && result, safeCheckPassed: result)
            })
        } else {
            goOption(autoOpenURL.isOn)
        }
    }
    
    func promptAlert(_ url:String, safeCheckPassed:Bool) {
        let alertController = UIAlertController(title: "Confirm to go?", message: "\(url)\(safeCheckPassed ? "\(googleSafeBrowsing.isOn ? "\n\nThis url is considered as safe in Google Safe Browsing" : "")" : "\n\nWarning: \(internetDown ? "Google Safe Browsing check is skipped due to no internet access" : "This url is NOT considered as safe in Google Safe Browsing")")", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Go", style: (safeCheckPassed ? .default : .destructive)) { (action) in
            self.goToURL(url)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func nonURLAlert(_ content:String) {
        let alertController = UIAlertController(title: "Invalid URL format", message: "Non URL content is read.\n\n \(content)", preferredStyle: .actionSheet)
        let alertSearch = UIAlertAction(title: "Internet Search", style: .default) { (action) in
            print("x-web-search://?\(content)")
            self.goToURL("x-web-search://?\(content)")
        }
        let alertCopy = UIAlertAction(title: "Copy to Clipboard", style: .default) { (action) in
            UIPasteboard.general.string = content
            HUD.flash(.labeledSuccess(title: "Success", subtitle: "Copied to Clipboard"), delay: 2.0)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertSearch)
        alertController.addAction(alertCopy)
        alertController.addAction(alertCancel)
        if alertController.popoverPresentationController != nil {
            alertController.popoverPresentationController!.sourceView = self.scanButton
            alertController.popoverPresentationController!.sourceRect = self.scanButton.bounds
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func switchOptionChanged(_ sender: AnyObject) {
        UserDefaults.standard.set([launchAtStart.isOn, googleSafeBrowsing.isOn, autoOpenURL.isOn], forKey: "switchOptions")
        UserDefaults.standard.synchronize()
    }
    
    func setInitialSwitchOptions() {
        let switchOptions = UserDefaults.standard.object(forKey: "switchOptions") as! [Bool]
        launchAtStart.isOn = switchOptions[0]
        googleSafeBrowsing.isOn = switchOptions[1]
        autoOpenURL.isOn = switchOptions[2]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

