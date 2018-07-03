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
        
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=***REMOVED***").responseJSON { response in
            
            let decoder = JSONDecoder()
            let place = try! decoder.decode(PlacesResponse.self, from: response.data!)
            
            completion(place.result)
            
        }
    }
}
