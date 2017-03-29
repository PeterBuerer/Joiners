//
//  NSPersistentContainer+Joiners.swift
//  Joiners
//
//  Created by Peter Buerer on 3/22/17.
//  Copyright © 2017 Peter Buerer. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    static let joinerContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Joiners")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: Handle error gracefully...not like this?
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveViewContext() -> Bool {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                return true
            }
            catch {
                // TODO: Replace this with code to handle the error appropriately
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return true
    }
}
