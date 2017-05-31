//
//  Favorite.swift
//  SeatGeek
//
//  Created by Eric on 5/31/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import Foundation

class Favorite {
    
    static func isFavorite(id: String) -> Bool {
        
        if let didFavor = UserDefaults.standard.object(forKey: id) as? Bool {
            return didFavor
        } else {
            return false
        }        
    }
    static func setFavorite(id: String, isFavorited: Bool) {
        UserDefaults.standard.set(isFavorited, forKey: id)
        UserDefaults.standard.synchronize()
    }
}
