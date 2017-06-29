//
//  Photo+CoreDataProperties.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-10.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @NSManaged var url: String?
    @NSManaged var imageData: NSData?
    @NSManaged var locationFood: LocationFood?

}
