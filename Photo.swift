//
//  Photo.swift
//  VirtualTourist
//
//  Created by ecraya14 on 30/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//
import UIKit
import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    convenience init(id: String, url: String, image: NSData?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.url = url
            self.image = image
            
            
        
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
