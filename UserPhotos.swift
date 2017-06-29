//
//  UserPhotos+CoreDataClass.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-30.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import Foundation
import CoreData


public class UserPhotos: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entity(forEntityName: "UserPhotos", in:context){
            
              self.init(entity:ent, insertInto: context)
            
        }
            
        else {
            fatalError("Unable to find Entity")
        }
    }

}
