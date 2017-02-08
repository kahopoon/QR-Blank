//
//  CoreData.swift
//  QR Blank
//
//  Created by Ka Ho on 8/2/2017.
//  Copyright © 2017 Ka Ho. All rights reserved.
//

import UIKit
import CoreData

class CoreData {
    
    static func stack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    static func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        // Get the stack
        let stack = CoreData.stack()
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "ScannedQR")
        fr.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        
        // Create the FetchedResultsController
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    static func getScannedHistory() -> [ScannedQR]? {
        do {
            var scannedQR:[ScannedQR] = []
            let fetchController = CoreData.fetchedResultsController()
            try fetchController.performFetch()
            let scannedQRCount = try fetchController.managedObjectContext.count(for: fetchController.fetchRequest)
            for index in 0..<scannedQRCount {
                scannedQR.append(fetchController.object(at: IndexPath(row: index, section: 0)) as! ScannedQR)
            }
            return scannedQR
        } catch {
            return nil
        }
    }
    
    static func saveScannedQR(isURL: Bool, content: String) {
        do {
            let stack = CoreData.stack()
            let _ = ScannedQR(isURL: isURL, content: content, context: stack.context)
            try stack.saveContext()
        } catch {
            print("add core data failed")
        }
    }
    
    static func removeAllScannedQR() {
        do {
            let scannedQRCodes = CoreData.getScannedHistory()
            if scannedQRCodes != nil {
                for qrCode in scannedQRCodes! {
                    CoreData.stack().context.delete(qrCode)
                }
            }
            try CoreData.stack().saveContext()
        } catch {
            print("delte core data failed")
        }
    }
    
}
