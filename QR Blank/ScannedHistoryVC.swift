//
//  ScannedHistoryVC.swift
//  QR Blank
//
//  Created by Ka Ho on 8/2/2017.
//  Copyright © 2017 Ka Ho. All rights reserved.
//

import UIKit
import PKHUD

class ScannedHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var QRCodes:[ScannedQR] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAutoLayout()
        
        let savedQRCodes = CoreData.getScannedHistory()
        if savedQRCodes != nil {
            QRCodes = savedQRCodes!
            tableView.reloadData()
        }
    }
    
    func tableViewAutoLayout() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QRCodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScannedHistoryVCCell", for: indexPath) as! ScannedHistoryVCCell

        cell.initWithData(QRCodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let qrCode = QRCodes[indexPath.row]
        if qrCode.isURL {
            goToURL(qrCode.contentString!)
        } else {
            copyToClipboard(qrCode.contentString!)
        }
    }
    
    func goToURL(_ url:String) {
        UIApplication.shared.openURL(URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!)
    }
    
    func copyToClipboard(_ content: String) {
        UIPasteboard.general.string = content
        HUD.flash(.labeledSuccess(title: "Success", subtitle: "Copied to clipboard"), delay: 1.0)
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure to remove all scanned history?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            DispatchQueue.main.async {
                CoreData.removeAllScannedQR()
                self.QRCodes.removeAll()
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

}
