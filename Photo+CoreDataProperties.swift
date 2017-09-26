//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by ecraya14 on 03/09/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var id: String?
    @NSManaged var url: String?
    @NSManaged var image: NSData?
    @NSManaged var pins: Pin?

}
