//
//  FlickrConstant.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-09.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        static let APIKey = "d75a582d2c564e84bc9d7bdfd176cb4b"
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        
    }
    
    struct Methods {
        static let SEARCH = "flickr.photos.getRecent"
    }
    
    struct ParameterKeys {
        static let API_KEY          = "api_key"
        static let METHOD           = "method"
        static let SAFE_SEARCH      = "safe_search"
        static let EXTRAS           = "extras"
        static let FORMAT           = "format"
        static let NO_JSON_CALLBACK = "nojsoncallback"
        static let BBOX             = "bbox"
        static let PAGE             = "page"
        static let PER_PAGE         = "per_page"
        static let SORT             = "sort"
        static let ACCURACY         = "accuracy"
        static let TAG              = "tag"
    }
    
    struct ParameterValues {
        static let JSON_FORMAT  = "json"
        static let URL_M        = "url_m"
    }
    
    
    struct BBoxParameters {
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
    
    
}