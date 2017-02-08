//
//  GoogleSafeBrowsingAPI.swift
//  QR Blank
//
//  Created by Ka Ho on 8/2/2017.
//  Copyright © 2017 Ka Ho. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GoogleSafeBrowsingAPI {
    
    private static let googleAPIKey = "AIzaSyDiizUkubGEdRZ2LCLPlmlwPJJhIbCe0_Q"
    
    static func checkURLSafe(_ url:String, completion:@escaping (_ result: Bool?) -> Void) {
        
        let client              = ["clientId":"qr-blank", "clientVersion":"1.0"]
        let threatTypes         = ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE",
                                   "THREAT_TYPE_UNSPECIFIED"]
        let platformTypes       = ["ANY_PLATFORM"]
        let threatEntryTypes    = ["URL"]
        let threatEntries       = [["url":"\(url)"]]
        let threatInfo              = ["threatTypes":threatTypes, "platformTypes":platformTypes,
                                   "threatEntryTypes":threatEntryTypes, "threatEntries":threatEntries] as [String : Any]
        let paras               = ["client":client as AnyObject, "threatInfo":threatInfo as
                                    AnyObject]
        
        request("https://safebrowsing.googleapis.com/v4/threatMatches:find?key=\(GoogleSafeBrowsingAPI.googleAPIKey)", method: .post, parameters: paras, encoding: JSONEncoding.default).responseJSON { (response) in
            
            if response.result.isFailure {
                completion(nil)
            } else {
                let result = JSON(response.result.value!).count == 0
                completion(result)
            }
        }
    }

}
