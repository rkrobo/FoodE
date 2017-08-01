//
//  UserRegion.swift
//  
//
//  Created by Rola Kitaphanich on 2017-08-01.
//
//

import CoreData
import MapKit
import Foundation


class UserRegion: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    convenience init(region: MKCoordinateRegion, context: NSManagedObjectContext){
        
        if let entity = NSEntityDescription.entity(forEntityName: "UserRegion", in:context){
            
            self.init(entity: entity, insertInto: context)
            self.region = region
        }
            
        else {
            fatalError("Unable to find Entity")
        }
    }
    
    
    var region: MKCoordinateRegion {
        
        set {
            cLong = newValue.center.longitude as NSNumber?
            cLat = newValue.center.latitude as NSNumber?
            sLong = newValue.span.longitudeDelta as NSNumber?
            sLat = newValue.span.latitudeDelta as NSNumber?
            
        }
        
        get {
            let centre = CLLocationCoordinate2DMake((cLat as? Double)!, (cLong as? Double)!)
            let span = MKCoordinateSpanMake((sLat as? Double)!, (sLong as? Double)!)
            
            return MKCoordinateRegionMake(centre, span)
        }
        
    }

    
}
