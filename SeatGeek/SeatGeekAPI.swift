//
//  SeatGeekAPI.swift
//  SeatGeek
//
//  Created by Eric on 5/31/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SeatGeekAPI {
    
    static let clientID: String = "NzcwNTc5M3wxNDk2MTg0MTU0LjE5"

    /// search SeatGeek with a specfic query
    static func queryEvents(_ searchText: String, completionHandler: @escaping (JSON) ->()) {
        
        let searchQuery = ("https://api.seatgeek.com/2/events?q=" + searchText)
    
        let parameters: Parameters = ["client_id":clientID]

        Alamofire.request(searchQuery, method: .get, parameters: parameters).responseJSON{ response in
            
            guard response.result.error == nil else
            {
                return completionHandler(nil)
            }
            if let value = response.result.value
            {
                let data = JSON(value)
                
                completionHandler(data)
            }
        }
    }
}
