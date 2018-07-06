//
//  GooglePlaces.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Alamofire

class GooglePlaces {
        
    class func lookUpPlace(placeId: String, completion: @escaping (Place) -> ()) {
        
        // get response from google places
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=***REMOVED***").responseJSON { response in
            
            let decoder = JSONDecoder()
            let data = try! decoder.decode(PlacesResponse.self, from: response.data!)
            
            completion(data.result)
            
        }
    }
    
    class func lookUpPhoto(ref: String, completion: @escaping (UIImage) -> ()) {
        // look up photo
        Alamofire.request("https://maps.googleapis.com/maps/api/place/photo?maxheight=50&photoreference=\(ref)&key=***REMOVED***").responseData { response in
            
            let photo = UIImage(data: response.result.value!)
            
            completion(photo!)
        }
    }
}
