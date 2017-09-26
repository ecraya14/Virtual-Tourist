//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by ecraya14 on 01/09/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//
import MapKit
import UIKit
import CoreData

class CoreDataViewController: UIViewController {

   
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}

