//
//  Pin.swift
//  VirtualTourist
//
//  Created by ecraya14 on 30/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {


    //in order to conform to MKAnnotation
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
    }
    
    convenience init (latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    

}
