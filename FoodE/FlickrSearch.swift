//
//  FlickrSearch.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-09.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
    
    func getPhotosForPin(_ pin: LocationFood, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
         let sort = randomPhotos(pin)
        
        let parameters = [
            ParameterKeys.METHOD: Methods.SEARCH,
            ParameterKeys.EXTRAS: ParameterValues.URL_M,
            ParameterKeys.FORMAT: ParameterValues.JSON_FORMAT,
            ParameterKeys.NO_JSON_CALLBACK: "1",
            ParameterKeys.SAFE_SEARCH: "1",
            ParameterKeys.BBOX: createBoundingBoxString(pin),
            ParameterKeys.PAGE: pageNumber,
            ParameterKeys.PER_PAGE: 21,
            ParameterKeys.SORT: sort,
            ParameterKeys.ACCURACY: 16,
            ParameterKeys.TEXT: "restaurant+food"
            ] as [String : Any]
        
        
        taskForGETMethod(nil, parameters: parameters as [String : AnyObject]?, parseJSON: true) { (JSONResult, error) in
            
            guard  error == nil else{
                
                completionHandler(false, "there was an error in the request")
                return
                
            }
            if let photosDictionary = JSONResult?.value(forKey: "photos") as? [String: AnyObject],
                
                let photosArray = photosDictionary["photo"] as? [[String: AnyObject]],
                
                let numofPages = photosDictionary["pages"] as? Int {
                
                if(photosArray.count == 0 ){
                    print("There are no photos for this location")
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    pin.locationPages = numofPages as NSNumber?
                    
                    for photoDictionary in photosArray {
                        
                        guard let photoURLString = photoDictionary["url_m"] else{
                            return
                        }
                        
                        let photo = Photos(annotUrl: photoURLString as! String, locationPin: pin, context: self.sharedContext)
                        
                        self.downloadImageForPhoto(photo) { (success, errorString) in
                            if success {
                                DispatchQueue.main.async(execute: {
                                    CoreDataStack.sharedInstance().save()
                                    completionHandler(true, nil)
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    completionHandler(false, errorString)
                                })
                            }
                        }
                    }
                })
            }
            else {
                completionHandler(false, "Unable to download Photos for the location")
            }
        }

        
    }
   
    func randomPhotos(_ pin:LocationFood) -> String {
        
        if let numPages = pin.locationPages {
            var numPagesInt = numPages as! Int
            if numPagesInt > 200 {
                numPagesInt = 200
            }
            pageNumber = Int((arc4random_uniform(UInt32(numPagesInt)))) + 1
            
            print("Printing from pageNumber: ",pageNumber)
        }
        
        let possibleSorts = [" date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, årelevance"]
        
        let sortBy = possibleSorts[Int((arc4random_uniform(UInt32(possibleSorts.count))))]
        
        return sortBy
        
    }
    
    
    func downloadImageForPhoto(_ photo: Photos, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        taskForGETMethod(photo.url, parameters: nil, parseJSON: false) { (result, error) in
            
            if error != nil {
                
                completionHandler(false, "Unable to download Photo")
            } else {
                if let result = result {
                    
                    DispatchQueue.main.async(execute: {
                        
                        photo.imageData =  result as? NSData
                        
                        completionHandler(true, nil)
                    })
                } else {
                    completionHandler(false, "Unable to download Photo")
                }
            }
        }
    }
    
    func createBoundingBoxString(_ pin: LocationFood) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BBoxParameters.BOUNDING_BOX_HALF_WIDTH, BBoxParameters.LON_MIN)
        let bottom_left_lat = max(latitude - BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MIN)
        let top_right_lon = min(longitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LON_MAX)
        let top_right_lat = min(latitude + BBoxParameters.BOUNDING_BOX_HALF_HEIGHT, BBoxParameters.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }


}
