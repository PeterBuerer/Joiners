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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save() -> Bool {
        let context = self.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            }
            catch {
                // TODO: Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                // TODO: update 
//                return false
            }
        }
        return true
    }
}
