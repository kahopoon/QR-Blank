//
//  ScannedHistoryVCCell.swift
//  QR Blank
//
//  Created by Ka Ho on 8/2/2017.
//  Copyright © 2017 Ka Ho. All rights reserved.
//

import UIKit

class ScannedHistoryVCCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    func initWithData(_ source: ScannedQR) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: source.createDate as! Date)
        
        contentLabel.text = source.contentString
        
        actionButton.setTitle(source.isURL ? "Open" : "Copy", for: .normal)
        actionButton.layer.cornerRadius = 5
    }

}
