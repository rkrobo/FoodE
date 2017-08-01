//
//  Location+CoreDataClass.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-03-29.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import UIKit
import CoreData
import MapKit


class LocationFood: NSManagedObject, MKAnnotation {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(coordinate : CLLocationCoordinate2D , placeID: NSString? = "", context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "LocationFood", in: context)!
        super.init(entity: entity, insertInto: context)
        self.latitude = coordinate.latitude as NSNumber?
        self.longitude = coordinate.longitude as NSNumber?
        self.placeID = placeID
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake((latitude as? Double)!, (longitude as? Double)!)
        }
        set {
            self.latitude = newValue.latitude as NSNumber?
            self.longitude = newValue.longitude as NSNumber?
        }
    }

}

