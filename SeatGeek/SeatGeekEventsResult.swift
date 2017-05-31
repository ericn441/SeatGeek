//
//  SeatGeekEventsResult.swift
//  SeatGeek
//
//  Created by Eric on 5/31/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import Foundation
import SwiftyJSON

class SeatGeekEventsResult {
    
    private var parsedSearchItems: [SearchItem] = []

    init(json: JSON) {
        
        for results in json["events"].arrayValue {
            
            let id = results["id"].stringValue
            let title = results["title"].stringValue
            let locationDetail = results["venue"]["display_location"].stringValue
            let time = convertToCST(utcTime: results["datetime_local"].stringValue)
            let imageURL = results["performers"][0]["image"].stringValue
            
            self.parsedSearchItems.append(SearchItem(id: id, title: title, detail: locationDetail, time: time, imageURL: imageURL, image: nil, didFavor: Favorites.isFavorite(id: id)))
            
        }
    }

    public func getParsedResults() -> [SearchItem] {
        return parsedSearchItems
    }
    
    private func convertToCST(utcTime: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date = dateFormatter.date(from: utcTime) // create date from UTC string
        
        // change to readable time format and local time zone
        dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
    }
}
