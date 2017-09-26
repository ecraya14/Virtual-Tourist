//
//  CoreDataStackManager.swift
//  Virtual Tourist
//
//  Created by ecraya14 on 30/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import Foundation
import CoreData



class CoreDataStackManager {

    
    lazy var applicationDocumentsDirectory: NSURL = {
       
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return paths[paths.count-1]
        
    }()
    
    //the model already created called 'Model'
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    // Create the store coordinator
    // Create a persistingContext (private queue) and a child one (main queue)
    // create a context and add connect it to the coordinator
    // Create a background context child of main context
    
    lazy var persistenStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let path = self.applicationDocumentsDirectory.URLByAppendingPathComponent("model.sqlite")
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: path, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating/loading the application's saved data"
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "persistentStoreCoordinator", code: 9999, userInfo: dict)
            // using abort() for the time being causes the application to generate a crash log and terminate. do not use abort() with a app that's going to be released.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    //returns the managed object context for the application
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistenStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func save() {
     
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                //using abort to create crash log, will not be releasing this app
                NSLog("Error: \(error as NSError) , \((error as NSError).userInfo)")
                abort()
            }
        }
    }
    
    
    class func sharedInstance() -> CoreDataStackManager {
        
        struct Static {
            static let coreDataManager = CoreDataStackManager()
        }
        
        return Static.coreDataManager
    }
}
