//
//  ScannedQR+CoreDataProperties.swift
//  
//
//  Created by Ka Ho on 8/2/2017.
//
//

import Foundation
import CoreData


extension ScannedQR {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScannedQR> {
        return NSFetchRequest<ScannedQR>(entityName: "ScannedQR");
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var isURL: Bool
    @NSManaged public var contentString: String?

}
