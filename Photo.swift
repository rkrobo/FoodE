//
//  Photo+CoreDataClass.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-10.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

public class Photo: NSManagedObject {
    
    convenience init(annotUrl:String, locationPin:LocationFood, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "PhotoFood", in:context){
            
            self.init(entity:ent, insertInto: context)
            
            url = annotUrl
            
            locationFood = locationPin
            
        }
            
        else {
            fatalError("Unable to find Entity")
        }
    }

}
