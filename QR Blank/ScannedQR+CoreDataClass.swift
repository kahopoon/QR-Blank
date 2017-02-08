//
//  ScannedQR+CoreDataClass.swift
//  
//
//  Created by Ka Ho on 8/2/2017.
//
//

import Foundation
import CoreData


public class ScannedQR: NSManagedObject {

    convenience init(isURL: Bool, content: String = "New Note", context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "ScannedQR", in: context) {
            self.init(entity: ent, insertInto: context)
            self.createDate     = Date() as NSDate?
            self.isURL          = isURL
            self.contentString  = content
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
