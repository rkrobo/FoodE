//
//  FlickrClient.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-09.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit
import CoreData

class FlickrClient: NSObject {
    
    
    static let sharedInstance = FlickrClient()
    
    var session: URLSession
    
    var pageNumber = 1
    
    var sortBy = 1
    
    override init() {
        session = URLSession.shared
    }
    
    func taskForGETMethod(_ url: String?, parameters: [String : AnyObject]?, parseJSON: Bool, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var urlString = (url != nil) ? url : Constants.BASE_URL
        
        if parameters != nil {
            var mutableParameters = parameters
            mutableParameters![ParameterKeys.API_KEY] = Constants.APIKey as AnyObject?
            urlString = urlString! + FlickrClient.escapedParameters(mutableParameters!)
        }
        
        let url = URL(string: urlString!)!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
           
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                completionHandler(nil, NSError(domain: "getTask", code: 2, userInfo: nil))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                var errorCode = 0 /* technical error */
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    errorCode = response.statusCode
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                DispatchQueue.main.async(execute: {
                    completionHandler(nil, NSError(domain: "getTask", code: errorCode, userInfo: nil))
                })
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if parseJSON {
                FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            } else {
                completionHandler(data as AnyObject?, nil)
            }
            
        })
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helper Methods
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    /* Parsing JSON */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] as AnyObject!
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }

}
